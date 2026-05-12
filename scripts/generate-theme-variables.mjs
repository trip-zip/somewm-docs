#!/usr/bin/env node
// Generate the Theme Variables reference page from @beautiful LDoc tags.
//
// Usage:
//   node scripts/generate-theme-variables.mjs \
//     --source /home/jimmy/tools/some \
//     --prelude docs/reference/beautiful/_theme-variables-prelude.md \
//     --out docs/reference/beautiful/theme-variables.md \
//     --ref main

import { readdir, readFile, writeFile, stat } from 'node:fs/promises';
import { join, relative } from 'node:path';
import { parseLuaContent, findBeautifulReferences } from './lib/ldoc-parse.mjs';
import { table, frontmatter, sourceLink } from './lib/mdx-emit.mjs';

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 2) {
    const key = argv[i].replace(/^--/, '');
    args[key] = argv[i + 1];
  }
  return args;
}

async function* walkLua(dir, root) {
  const entries = await readdir(dir, { withFileTypes: true });
  for (const e of entries.sort((a, b) => a.name.localeCompare(b.name))) {
    const p = join(dir, e.name);
    if (e.isDirectory()) {
      yield* walkLua(p, root);
    } else if (e.isFile() && e.name.endsWith('.lua')) {
      yield { abs: p, rel: relative(root, p) };
    }
  }
}

// Files at <source>/ root (not under lua/) that we also scan for beautiful.X
// references. somewmrc.lua is the default user config; in 2.0+ it exercises
// theme vars the documented modules don't.
const EXTRA_LUA_ROOT_FILES = ['somewmrc.lua'];

// `beautiful.X` lookups in source code that are NOT theme variables: they are
// functions or submodules of the beautiful module itself. Excluded from the
// Undocumented (Used in Code) section.
const BEAUTIFUL_NON_VARIABLES = new Set([
  'init', 'gtk', 'theme_assets', 'xresources',  // submodules
  'get', 'get_font', 'get_merged_font', 'get_font_height',  // functions
  'mt',  // metatable
]);

const MODULE_LABELS = {
  awful: 'awful',
  wibox: 'wibox',
  naughty: 'naughty',
  gears: 'gears',
  ruled: 'ruled',
  menubar: 'menubar',
};

// SomeWM-specific groupings: pulled out into their own section since they
// don't exist in upstream AwesomeWM and deserve visibility. Members are
// matched by prefix.
const SOMEWM_PREFIXES = ['systray_', 'screenshot_', 'shadow_', 'lockscreen_'];

function moduleBucket(record) {
  if (SOMEWM_PREFIXES.some((p) => record.name.startsWith(p))) return '_somewm';
  const seg = record.file.split('/')[1] || 'root';
  return MODULE_LABELS[seg] || 'root';
}

// Legacy anchor IDs preserved so existing cross-page links keep working
// after the page was restructured to group by module instead of feature.
const LEGACY_ANCHORS = {
  naughty: 'notifications',
};

function moduleHeading(bucket) {
  if (bucket === '_somewm') return 'SomeWM Extensions';
  const anchor = LEGACY_ANCHORS[bucket];
  if (anchor) return `${bucket} {#${anchor}}`;
  return bucket;
}

const MODULE_ORDER = ['awful', 'wibox', 'naughty', 'gears', 'ruled', 'menubar', 'root', '_somewm'];

async function gitSha(source) {
  const { execFile } = await import('node:child_process');
  return new Promise((resolve) => {
    execFile('git', ['-C', source, 'rev-parse', 'HEAD'], (err, stdout) => {
      resolve(err ? 'unknown' : stdout.trim());
    });
  });
}

async function main() {
  const args = parseArgs(process.argv);
  const source = args.source;
  const out = args.out;
  const preludePath = args.prelude;
  const ref = args.ref || 'main';

  if (!source || !out) {
    console.error('Usage: --source <path> --out <path> [--prelude <path>] [--ref <git-ref>]');
    process.exit(2);
  }

  const luaRoot = join(source, 'lua');
  await stat(luaRoot);

  const documented = [];
  const allRefs = [];

  for await (const f of walkLua(luaRoot, source)) {
    const content = await readFile(f.abs, 'utf8');
    documented.push(...parseLuaContent(content, f.rel));
    allRefs.push(...findBeautifulReferences(content, f.rel));
  }

  for (const fname of EXTRA_LUA_ROOT_FILES) {
    const abs = join(source, fname);
    try {
      const content = await readFile(abs, 'utf8');
      documented.push(...parseLuaContent(content, fname));
      allRefs.push(...findBeautifulReferences(content, fname));
    } catch {
      // file may not exist on this branch; that's fine
    }
  }

  const documentedNames = new Set(documented.map((r) => r.name));
  const undocumentedByName = new Map();
  for (const ref of allRefs) {
    if (documentedNames.has(ref.name)) continue;
    if (BEAUTIFUL_NON_VARIABLES.has(ref.name)) continue;
    if (!undocumentedByName.has(ref.name)) undocumentedByName.set(ref.name, []);
    undocumentedByName.get(ref.name).push(ref);
  }

  const byModule = new Map();
  for (const r of documented) {
    const b = moduleBucket(r);
    if (!byModule.has(b)) byModule.set(b, []);
    byModule.get(b).push(r);
  }
  for (const list of byModule.values()) {
    list.sort((a, b) => a.name.localeCompare(b.name));
  }

  const sha = await gitSha(source);
  const shortSha = sha.slice(0, 10);
  const totalDocumented = documented.length;
  const totalUndocumented = undocumentedByName.size;

  let prelude = '';
  if (preludePath) {
    try {
      prelude = await readFile(preludePath, 'utf8');
    } catch (e) {
      console.warn(`Prelude not found at ${preludePath}; continuing without it.`);
    }
  }

  const sections = [];
  for (const bucket of MODULE_ORDER) {
    const records = byModule.get(bucket);
    if (!records || records.length === 0) continue;
    const heading = moduleHeading(bucket);
    const rows = records.map((r) => [
      r.deprecated ? `~~\`${r.name}\`~~` : `\`${r.name}\``,
      r.type ? `\`${r.type}\`` : '',
      r.description || (r.deprecated ? '_deprecated_' : '_(no description)_'),
      sourceLink(r.file, r.line, ref),
    ]);
    const tbl = table(['Variable', 'Type', 'Description', 'Source'], rows);
    sections.push(`## ${heading}\n\n${records.length} entries.\n\n${tbl}`);
  }

  let undocumentedSection = '';
  if (undocumentedByName.size > 0) {
    const rows = [...undocumentedByName.entries()]
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([name, refs]) => {
        const links = refs.slice(0, 3).map((r) => sourceLink(r.file, r.line, ref)).join(', ');
        const more = refs.length > 3 ? ` _(+${refs.length - 3} more)_` : '';
        return [`\`${name}\``, `${links}${more}`];
      });
    const tbl = table(['Variable', 'Used at'], rows);
    undocumentedSection = [
      '## Undocumented (Used in Code)',
      '',
      `${undocumentedByName.size} theme variables are read in source but lack an \`@beautiful\` annotation. These work, but their type and intended values are not formally documented. Filing upstream PRs to add LDoc is welcome.`,
      '',
      tbl,
    ].join('\n');
  }

  const fm = frontmatter({
    sidebar_position: 2,
    title: 'Theme Variables',
    description: 'Complete reference of beautiful theme variables in SomeWM',
  });

  const header = [
    fm,
    '',
    "import SomewmOnly from '@site/src/components/SomewmOnly';",
    '',
    '# Theme Variables',
    '',
    `Generated from \`@beautiful\` LDoc annotations in the [SomeWM source](https://github.com/trip-zip/somewm/tree/${ref}/lua). Last sync: \`${shortSha}\`. **${totalDocumented} documented**, ${totalUndocumented} used-but-undocumented.`,
    '',
    'See the [Theme Tutorial](/docs/tutorials/theme) for how to apply these in a custom theme.',
    '',
  ].join('\n');

  const seeAlso = [
    '## See Also',
    '',
    '- [Theme Tutorial](/docs/tutorials/theme) – Build a custom theme',
    '- [Key Names](/docs/reference/key-names) – Common keybinding key names',
    '- [beautiful (AwesomeWM upstream docs)](https://awesomewm.org/apidoc/libraries/beautiful.html) – Full upstream API',
    '',
    `<!-- generator: scripts/generate-theme-variables.mjs | source ref: ${ref} @ ${shortSha} | regenerate with \`npm run generate:reference\` -->`,
  ].join('\n');

  const body = [
    header,
    prelude.trim(),
    '',
    ...sections,
    '',
    undocumentedSection,
    '',
    seeAlso,
    '',
  ]
    .filter((s) => s !== null && s !== undefined)
    .join('\n');

  await writeFile(out, body);
  console.log(
    `wrote ${out}: ${totalDocumented} documented in ${byModule.size} modules, ${totalUndocumented} undocumented`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
