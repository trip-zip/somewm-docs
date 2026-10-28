#!/usr/bin/env node
// Check option names against the Lua wrappers. Defaults and behaviour still
// require review. Run with --source /path/to/kiln and optionally --docs kiln.
import {readFile, readdir} from 'node:fs/promises';
import {join} from 'node:path';
import {homedir} from 'node:os';

const args = process.argv.slice(2);
function option(name, fallback) {
  const i = args.indexOf(name);
  if (i < 0) return fallback;
  if (!args[i + 1]) throw new Error(`${name} requires a path`);
  return args[i + 1];
}
const source = option('--source', join(homedir(), 'tools/kiln'));
const docs = option('--docs', 'kiln');
let failures = 0, checked = 0;

function functions(lua, module) {
  const matches = [...lua.matchAll(new RegExp(`^function ${module}\\.(\\w+)\\(`, 'gm'))];
  return new Map(matches.map((m, i) => [m[1], lua.slice(m.index, matches[i + 1]?.index)]));
}
function fields(lua, variable) {
  return new Set([...lua.matchAll(new RegExp(`\\b${variable}\\.(\\w+)`, 'g'))].map(m => m[1]));
}
function rows(md) {
  const names = new Set();
  for (const line of md.split('\n')) {
    if (!line.startsWith('|')) continue;
    for (const m of line.slice(1).split('|')[0].matchAll(/`([^`]+)`/g)) names.add(m[1].replace(/\(.*$/, ''));
  }
  return names;
}
async function check(file, expected, heading = 'Options') {
  const md = await readFile(join(docs, 'reference', file), 'utf8');
  const section = md.split(`## ${heading}\n`)[1]?.split(/^#{2,3} /m)[0] ?? '';
  const actual = rows(section);
  const missing = [...expected].filter(k => !actual.has(k));
  const extra = [...actual].filter(k => !expected.has(k));
  if (missing.length || extra.length) {
    failures++;
    console.error(`${file}: missing [${missing}], extra [${extra}]`);
  }
  checked++;
}
const widgets = functions(await readFile(join(source, 'lua/kiln/widgets.lua'), 'utf8'), 'widgets');
// reset is called by config reload, not a drawing function.
widgets.delete('reset');
const menu = await readFile(join(source, 'lua/kiln/menu.lua'), 'utf8');
for (const [name, lua] of widgets) {
  let expected = fields(lua, 'cfg');
  if (name === 'layoutlist') {
    // layoutlist supplies items and screen; show reads the remaining options.
    expected = fields(functions(menu, 'menu').get('show'), 'cfg');
    expected.delete('items');
    expected.delete('screen');
  }
  await check(`widgets/${name}.md`, expected);
}
for (const file of await readdir(join(docs, 'reference/widgets'))) {
  if (file.endsWith('.md') && file !== 'common.md' && !widgets.has(file.slice(0, -3))) {
    failures++;
    console.error(`widgets/${file}: no source function`);
  }
}
const uiSource = await readFile(join(source, 'lua/kiln/ui.lua'), 'utf8');
const ui = functions(uiSource, 'ui');
for (const name of ['text', 'image', 'scroll']) await check(`ui/${name}.md`, fields(ui.get(name), 'cfg'));
const common = uiSource.split('local function to_declaration(')[1].split('function ui.box(')[0];
const commonFields = fields(common, 'cfg');
// Handler names are indexed in a loop, so collect their literal registry too.
for (const m of uiSource.match(/local handler_names = \{([^}]+)\}/)[1].matchAll(/"([^"]+)"/g)) commonFields.add(m[1]);
await check('ui/common.md', commonFields, 'Element options');
const widgetFields = fields(ui.get('widget'), 'spec');
widgetFields.add('[1]');
await check('ui/widget.md', widgetFields);
const desktop = await readFile(join(source, 'lua/kiln/desktop.lua'), 'utf8');
await check('ui/bar.md', fields(desktop, 'cfg'));
const popup = await readFile(join(source, 'lua/kiln/popup.lua'), 'utf8');
await check('ui/popup.md', fields(popup, 'spec'));
const example = await readFile('static/examples/kiln/forms.lua', 'utf8');
const inline = await readFile(join(docs, 'reference/widgets/_lua/forms.mdx'), 'utf8');
if (inline !== `\`\`\`lua\n${example}\`\`\`\n`) {
  failures++;
  console.error('forms.mdx differs from the downloadable forms.lua');
}
console.log(`${checked} option tables checked; ${failures} failures.`);
process.exitCode = failures ? 1 : 0;
