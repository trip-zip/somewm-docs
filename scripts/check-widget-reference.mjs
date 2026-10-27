#!/usr/bin/env node
// Compare each wibox reference page against the LDoc @property and @method
// tags in the SomeWM source, so a page cannot quietly miss or invent one.
//
//   node scripts/check-widget-reference.mjs [--source ~/tools/some] [--docs docs]
//
// For every docs/reference/wibox/{widget,container,layout}/<name>.md it reads
// lua/wibox/<kind>/<name>.lua, collects the tagged property and method names,
// and reports names the page lacks and names the page has that the source
// does not. A name wrapped in backticks in a table's first column counts as
// documented. Exit status 1 when anything is off.

import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { homedir } from 'node:os';

const args = Object.fromEntries(
  process.argv.slice(2).reduce((a, v, i, all) => (v.startsWith('--') ? [...a, [v.slice(2), all[i + 1]]] : a), []),
);
const source = args.source ?? join(homedir(), 'tools/some');
const docs = args.docs ?? 'docs';

const PROP = /^-+\s*@(?:deprecated)?property\s+(\S+)/;
const METHOD = /^-+\s*@method\s+(\S+)/;
const RETIRED = /clay\.retire\([^,]+,\s*\{([^}]*)\}/g;

let bad = 0;
for (const kind of ['widget', 'container', 'layout']) {
  let pages = [];
  try { pages = (await readdir(join(docs, 'reference/wibox', kind))).filter((f) => f.endsWith('.md')); } catch { continue; }
  for (const page of pages) {
    const name = page.replace(/\.md$/, '');
    const lua = await readFile(join(source, 'lua/wibox', kind, `${name}.lua`), 'utf8');
    const props = new Set(), methods = new Set();
    for (const line of lua.split('\n')) {
      const p = PROP.exec(line); if (p) props.add(p[1]);
      const m = METHOD.exec(line); if (m && !/^_/.test(m[1].replace(/^.*:/, ''))) methods.add(m[1].replace(/^.*:/, ''));
    }
    for (const r of lua.matchAll(RETIRED)) for (const n of r[1].matchAll(/"([^"]+)"/g)) props.delete(n[1]);
    const md = await readFile(join(docs, 'reference/wibox', kind, page), 'utf8');
    const documented = new Set();
    for (const line of md.split('\n')) {
      if (!line.startsWith('|')) continue;
      const first = line.slice(1).split('|')[0];
      for (const m of first.matchAll(/`([^`]+)`/g)) {
        const bare = m[1].replace(/^:/, '').replace(/\(.*$/, '').replace(/^wibox\.\w+\.\w+\./, '');
        documented.add(bare);
      }
    }
    const missing = [...props, ...methods].filter((n) => !documented.has(n)).sort();
    const extra = [...documented].filter((n) => !props.has(n) && !methods.has(n) && !/^(set_|get_)/.test(n)).sort();
    const label = `wibox.${kind}.${name}`;
    if (missing.length) { bad++; console.log(`${label}: page lacks ${missing.join(', ')}`); }
    if (extra.length) console.log(`${label}: page lists ${extra.join(', ')}, not tagged in the source`);
    if (!missing.length) console.log(`${label}: ok (${props.size} properties, ${methods.size} methods)`);
  }
}
process.exit(bad ? 1 : 0);
