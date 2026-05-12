#!/usr/bin/env node
// Generate the "All Keysyms" reference page from xkbcommon-keysyms.h.
//
// Usage:
//   node scripts/generate-keysyms.mjs \
//     --header /usr/include/xkbcommon/xkbcommon-keysyms.h \
//     --out docs/reference/key-names-all.md

import { readFile, writeFile } from 'node:fs/promises';
import { table, frontmatter, details } from './lib/mdx-emit.mjs';

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 2) {
    const key = argv[i].replace(/^--/, '');
    args[key] = argv[i + 1];
  }
  return args;
}

const DEFINE = /^#define\s+XKB_KEY_(\S+)\s+(0x[0-9a-fA-F]+)\s*(?:\/\*\s*(.*?)\s*\*\/)?\s*$/;

// A comment block whose first content line looks like a section header
// (short, doesn't start with "Copyright", isn't part of the file preamble).
// Returns the trimmed first content line as the section name, or null.
function detectSection(commentLines) {
  const content = commentLines
    .map((l) => {
      let s = l.trim();
      s = s.replace(/^\/\*+/, '');     // strip /* or /** at start
      s = s.replace(/\*+\/\s*$/, '');  // strip */ at end
      s = s.replace(/^\*+\s?/, '');    // strip leading * decoration
      return s.trim();
    })
    .filter((l) => l.length > 0);
  if (content.length === 0) return null;
  const first = content[0];
  if (/^@file\b/i.test(first)) return null;
  if (/copyright|all rights reserved|permission|software/i.test(first)) return null;
  if (/the .x11 window system protocol/i.test(first)) return null;
  if (/mnemonic names|before adding|before removing|when adding/i.test(first)) return null;
  if (/^note:?\b/i.test(first)) return null; // NOTE: lines are commentary, not banners
  if (first.length > 100) return null;
  // Many banners are wrapped paragraphs ("TTY function keys, cleverly chosen
  // to map to ASCII..."). Take just the leading noun phrase.
  let head = first.split(/[,;.:]/)[0].trim();
  // Strip parenthesized URLs/notes after the name ("Sinhala (http://unicode...)").
  head = head.replace(/\s*\([^)]*$/, '').trim();
  if (!head || head.length === 0) return null;
  // Filter trivial residues like decoration-only banners.
  if (/^[-*=/\\\s]+$/.test(head)) return null;
  return head;
}

function noteFromComment(comment) {
  if (!comment) return '';
  const lower = comment.toLowerCase();
  if (lower.startsWith('deprecated')) return comment;
  if (lower.startsWith('non-deprecated alias')) return comment;
  if (/^alias for/i.test(comment)) return comment;
  if (/^u\+[0-9a-f]{4,}/i.test(comment)) return comment;
  if (/^<u\+/i.test(comment)) return comment;
  return comment;
}

function isDeprecated(comment) {
  if (!comment) return false;
  return /^deprecated\b/i.test(comment.trim());
}

async function main() {
  const args = parseArgs(process.argv);
  const headerPath = args.header || '/usr/include/xkbcommon/xkbcommon-keysyms.h';
  const out = args.out;
  if (!out) {
    console.error('Usage: --header <path> --out <path>');
    process.exit(2);
  }

  const content = await readFile(headerPath, 'utf8');
  const lines = content.split('\n');

  const sections = []; // [{ name, entries: [{ name, hex, comment }] }]
  let current = { name: 'Special keysyms', entries: [] };
  sections.push(current);

  let inComment = false;
  let commentBuffer = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (!inComment) {
      const startsComment = /^\s*\/\*/.test(line);
      if (startsComment) {
        // Single-line comments are not section banners.
        if (/\*\//.test(line)) continue;
        inComment = true;
        commentBuffer = [line];
        continue;
      }

      const m = DEFINE.exec(line);
      if (m) {
        const [, name, hex, comment] = m;
        current.entries.push({ name, hex: hex.toLowerCase(), comment: comment || '' });
      }
      continue;
    }

    // inComment === true
    commentBuffer.push(line);
    if (/\*\//.test(line)) {
      inComment = false;
      const section = detectSection(commentBuffer);
      if (section) {
        // If the current section has no entries yet, treat the new banner as
        // a sub-note within the existing one — keeps "XFree86 vendor specific
        // keysyms" intact instead of fragmenting into ModeLock/Backlight/etc.
        if (current.entries.length === 0 && sections.length > 0) {
          current.name = current.name; // keep
        } else {
          current = { name: section, entries: [] };
          sections.push(current);
        }
      }
      commentBuffer = [];
    }
  }

  // Drop empty sections (banners with no following defines).
  const populated = sections.filter((s) => s.entries.length > 0);

  // Total count for sanity check.
  const total = populated.reduce((sum, s) => sum + s.entries.length, 0);

  const fm = frontmatter({
    sidebar_position: 11,
    title: 'All Keysyms',
    description: 'Full enumeration of xkbcommon keysym names accepted by SomeWM',
  });

  const intro = [
    '# All Keysyms',
    '',
    `Complete enumeration of every keysym name SomeWM accepts in \`awful.key\` bindings. **${total} keysyms** in ${populated.length} categories.`,
    '',
    'SomeWM resolves key names by calling `xkb_keysym_from_name()` (case-insensitive). Take any `XKB_KEY_*` name from this list, strip the `XKB_KEY_` prefix, and pass the remainder as a string.',
    '',
    '```lua',
    '-- These are equivalent because xkb_keysym_from_name is case-insensitive:',
    'awful.key({ modkey }, "Return",     function() awful.spawn(terminal) end)',
    'awful.key({ modkey }, "return",     function() awful.spawn(terminal) end)',
    '',
    '-- Multimedia and special keys use the literal XF86 name:',
    'awful.key({}, "XF86AudioRaiseVolume", function() ... end)',
    '```',
    '',
    'For the everyday key reference (modifiers, common keys, F-keys, media keys, mouse buttons), see **[Key Names](/docs/reference/key-names)**.',
    '',
    ':::note Source of truth',
    `This page is generated from \`${headerPath}\` on the build host. SomeWM links against the same libxkbcommon at runtime, so the lists are identical.`,
    ':::',
    '',
  ].join('\n');

  const sectionBlocks = populated.map((s) => {
    const rows = s.entries.map((e) => {
      const note = noteFromComment(e.comment);
      const nameCell = isDeprecated(e.comment) ? `~~\`${e.name}\`~~` : `\`${e.name}\``;
      return [nameCell, `\`${e.hex}\``, note];
    });
    const tbl = table(['Name', 'Hex', 'Notes'], rows);
    return details(`${s.name} (${s.entries.length} keys)`, tbl);
  });

  const footer = [
    '## See Also',
    '',
    '- [Key Names](/docs/reference/key-names) – Curated reference for everyday bindings',
    '- [Keybindings Tutorial](/docs/tutorials/keybindings) – Learn how to bind keys',
    '- [xkbcommon documentation](https://xkbcommon.org/doc/current/group__keysyms.html) – Upstream API reference',
    '',
    `<!-- generator: scripts/generate-keysyms.mjs | header: ${headerPath} | regenerate with \`npm run generate:reference\` -->`,
  ].join('\n');

  const body = [fm, '', intro, ...sectionBlocks, '', footer, ''].join('\n');
  await writeFile(out, body);
  console.log(`wrote ${out}: ${total} keysyms in ${populated.length} sections`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
