#!/usr/bin/env node
// Regenerate all auto-built reference pages for both doc versions.
//
// Creates temporary git worktrees of /home/jimmy/tools/some at the
// appropriate refs (main for 2.0-dev, release/1.4 for the versioned 1.4
// docs) so the generation is independent of what's currently checked out.
//
// Usage:
//   node scripts/regenerate-all.mjs
//   node scripts/regenerate-all.mjs --somewm-repo /custom/path/to/some

import { execFile } from 'node:child_process';
import { mkdtemp, rm, copyFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const execFileP = promisify(execFile);
const HERE = dirname(fileURLToPath(import.meta.url));
const DOCS_ROOT = join(HERE, '..');

function parseArgs(argv) {
  const args = { 'somewm-repo': '/home/jimmy/tools/some' };
  for (let i = 2; i < argv.length; i += 2) {
    args[argv[i].replace(/^--/, '')] = argv[i + 1];
  }
  return args;
}

async function run(cmd, args, opts = {}) {
  console.log(`$ ${cmd} ${args.join(' ')}`);
  const { stdout, stderr } = await execFileP(cmd, args, opts);
  if (stdout) process.stdout.write(stdout);
  if (stderr) process.stderr.write(stderr);
}

async function addWorktree(repo, ref, label) {
  const dir = await mkdtemp(join(tmpdir(), `somewm-gen-${label}-`));
  await run('git', ['-C', repo, 'worktree', 'add', '--detach', dir, ref]);
  return dir;
}

async function removeWorktree(repo, dir) {
  try {
    await run('git', ['-C', repo, 'worktree', 'remove', '--force', dir]);
  } catch (e) {
    console.warn(`failed to remove worktree ${dir}: ${e.message}`);
    try {
      await rm(dir, { recursive: true, force: true });
    } catch {}
  }
}

async function generateThemeVariables(source, outRel, preludeRel, ref) {
  await run('node', [
    join(HERE, 'generate-theme-variables.mjs'),
    '--source', source,
    '--prelude', join(DOCS_ROOT, preludeRel),
    '--out', join(DOCS_ROOT, outRel),
    '--ref', ref,
  ]);
}

async function generateKeysyms(outRel) {
  await run('node', [
    join(HERE, 'generate-keysyms.mjs'),
    '--header', '/usr/include/xkbcommon/xkbcommon-keysyms.h',
    '--out', join(DOCS_ROOT, outRel),
  ]);
}

async function main() {
  const args = parseArgs(process.argv);
  const repo = args['somewm-repo'];

  const mainTree = await addWorktree(repo, 'main', 'main');
  const v14Tree = await addWorktree(repo, 'release/1.4', '1.4');

  try {
    // Theme variables: per-version, since @beautiful coverage differs.
    await generateThemeVariables(
      mainTree,
      'docs/reference/beautiful/theme-variables.md',
      'docs/reference/beautiful/_theme-variables-prelude.md',
      'main',
    );
    await generateThemeVariables(
      v14Tree,
      'versioned_docs/version-1.4/reference/beautiful/theme-variables.md',
      'versioned_docs/version-1.4/reference/beautiful/_theme-variables-prelude.md',
      'release/1.4',
    );

    // Keysyms: version-independent (driven by system xkbcommon header).
    await generateKeysyms('docs/reference/key-names-all.md');
    await copyFile(
      join(DOCS_ROOT, 'docs/reference/key-names-all.md'),
      join(DOCS_ROOT, 'versioned_docs/version-1.4/reference/key-names-all.md'),
    );
    console.log('copied key-names-all.md to versioned_docs/version-1.4/');
  } finally {
    await removeWorktree(repo, mainTree);
    await removeWorktree(repo, v14Tree);
  }

  console.log('\ndone. Review the diff with: git status && git diff --stat docs/ versioned_docs/');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
