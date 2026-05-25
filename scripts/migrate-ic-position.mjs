#!/usr/bin/env node
// One-off migration: renames `ic_position` → `cat_open` in all CSV headers.
// Safe to re-run: files without `ic_position` are left untouched.

import { readdirSync, readFileSync, writeFileSync, statSync } from 'fs';
import { join, extname } from 'path';

const dataDir = new URL('../src/data', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');

function walkCsvs(dir) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      results.push(...walkCsvs(full));
    } else if (extname(entry) === '.csv') {
      results.push(full);
    }
  }
  return results;
}

let changed = 0;
let skipped = 0;

for (const file of walkCsvs(dataDir)) {
  const raw = readFileSync(file, 'utf8');
  // Strip BOM if present
  const content = raw.startsWith('﻿') ? raw.slice(1) : raw;
  const newline = content.includes('\r\n') ? '\r\n' : '\n';
  const lines = content.split(newline);
  const header = lines[0];

  // Only touch files that actually have ic_position as a header token
  const tokens = header.split(',');
  const colIdx = tokens.indexOf('ic_position');
  if (colIdx === -1) {
    skipped++;
    continue;
  }

  tokens[colIdx] = 'cat_open';
  lines[0] = tokens.join(',');
  // Preserve BOM if original had one
  const prefix = raw.startsWith('﻿') ? '﻿' : '';
  writeFileSync(file, prefix + lines.join(newline), 'utf8');
  changed++;
  console.log(`  updated: ${file}`);
}

console.log(`\nDone. ${changed} file(s) updated, ${skipped} file(s) skipped.`);
