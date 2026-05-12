// MDX emit helpers for generated reference pages.

const PIPE = /\|/g;
const NEWLINE = /\n/g;
const LT = /</g;
const GT = />/g;

// MDX 3.x parses any `<` as the start of a JSX tag, which fails on content
// like `<U+0020 SPACE>` or `<= 1`. Pre-escape angle brackets in cell content.
export function escapeCell(value) {
  if (value === null || value === undefined) return '';
  return String(value)
    .replace(PIPE, '\\|')
    .replace(NEWLINE, ' ')
    .replace(LT, '&lt;')
    .replace(GT, '&gt;')
    .trim();
}

export function table(headers, rows) {
  const head = `| ${headers.join(' | ')} |`;
  const sep = `| ${headers.map(() => '---').join(' | ')} |`;
  const body = rows.map((r) => `| ${r.map(escapeCell).join(' | ')} |`).join('\n');
  return [head, sep, body].filter(Boolean).join('\n');
}

export function details(summary, body) {
  return `<details>\n<summary>${summary}</summary>\n\n${body}\n\n</details>`;
}

export function frontmatter(fields) {
  const lines = ['---'];
  for (const [k, v] of Object.entries(fields)) {
    lines.push(`${k}: ${v}`);
  }
  lines.push('---');
  return lines.join('\n');
}

// Resolves a file:line reference into a GitHub blob URL.
// SomeWM source repo: https://github.com/trip-zip/somewm
export function sourceLink(file, line, ref = 'main') {
  const base = `https://github.com/trip-zip/somewm/blob/${ref}/${file}`;
  return `[${file.replace(/^lua\//, '')}:${line}](${base}#L${line})`;
}
