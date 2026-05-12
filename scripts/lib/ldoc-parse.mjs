// LDoc block parser for SomeWM @beautiful annotations.
//
// Parses Lua files for blocks of the form:
//
//   --- The tooltip border color.
//   -- @beautiful beautiful.tooltip_border_color
//   -- @param color
//   -- @see gears.color
//
// Returns one record per @beautiful tag found.

import { readFile } from 'node:fs/promises';

const BEAUTIFUL_TAG = /^@beautiful\s+beautiful\.(\S+)\s*$/;
const PARAM_TAG = /^@t?param(?:\[opt(?:=([^\]]+))?\])?\s+(\S+)/;
const DEPRECATED_TAG = /^@deprecated/;
const SEE_TAG = /^@see\s+(\S+)/;

// Recognizes the start of an LDoc block: --- (exactly three dashes).
// We deliberately exclude ---- (four or more) which are decorative separators.
const BLOCK_START = /^---(?!-)\s?(.*)$/;
// Continuation line: -- (any number of trailing dashes treated as content).
const BLOCK_CONT = /^--\s?(.*)$/;

export async function parseLuaFile(path, relativePath) {
  const content = await readFile(path, 'utf8');
  return parseLuaContent(content, relativePath);
}

export function parseLuaContent(content, relativePath) {
  const lines = content.split('\n');
  const blocks = [];
  let current = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const start = BLOCK_START.exec(line);
    const cont = BLOCK_CONT.exec(line);

    if (start) {
      if (current) blocks.push(current);
      current = { startLine: i + 1, lines: [start[1] ?? ''], file: relativePath };
    } else if (cont && current) {
      current.lines.push(cont[1] ?? '');
    } else if (current) {
      blocks.push(current);
      current = null;
    }
  }
  if (current) blocks.push(current);

  const records = [];
  for (const block of blocks) {
    const beautifulLine = block.lines.find((l) => BEAUTIFUL_TAG.test(l.trim()));
    if (!beautifulLine) continue;
    const name = BEAUTIFUL_TAG.exec(beautifulLine.trim())[1];

    const descLines = [];
    for (const raw of block.lines) {
      const l = raw.trim();
      if (l.startsWith('@')) break;
      if (l) descLines.push(l);
    }
    let description = descLines.join(' ').replace(/\s+/g, ' ').trim();
    // Strip markdown image refs ![alt](path) - the images live in upstream
    // AwesomeWM docs, not here. Replace with the alt text in brackets.
    description = description.replace(/!\[([^\]]*)\]\([^)]+\)/g, '[image: $1]');
    // Strip raw HTML anchors/divs that LDoc allows but MDX 3.x mishandles.
    description = description.replace(/<\/?(?:a|div|span|p|br)\b[^>]*>/gi, '');

    let type = '';
    let defaultValue = '';
    for (const raw of block.lines) {
      const m = PARAM_TAG.exec(raw.trim());
      if (m) {
        defaultValue = m[1] || '';
        type = m[2] || '';
        break;
      }
    }

    const deprecated = block.lines.some((l) => DEPRECATED_TAG.test(l.trim()));
    const seeRefs = block.lines
      .map((l) => SEE_TAG.exec(l.trim()))
      .filter(Boolean)
      .map((m) => m[1]);

    records.push({
      name,
      type,
      default: defaultValue,
      description,
      file: relativePath,
      line: block.startLine,
      deprecated,
      seeRefs,
    });
  }
  return records;
}

// Find every beautiful.X reference in source code (not LDoc tags) for the
// "Undocumented (Used in Code)" section. Matches `beautiful.foo_bar` outside
// of @beautiful tag lines and outside of strings.
export function findBeautifulReferences(content, relativePath) {
  const lines = content.split('\n');
  const refs = [];
  const seen = new Set();
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    // Skip LDoc tag lines so we don't double-count documented ones.
    if (/--.*@beautiful\s+beautiful\./.test(line)) continue;
    const regex = /\bbeautiful\.([a-zA-Z_][a-zA-Z0-9_]*)/g;
    let m;
    while ((m = regex.exec(line)) !== null) {
      const name = m[1];
      const key = `${name}\t${relativePath}\t${i + 1}`;
      if (seen.has(key)) continue;
      seen.add(key);
      refs.push({ name, file: relativePath, line: i + 1 });
    }
  }
  return refs;
}
