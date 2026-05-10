#!/usr/bin/env node
// Parses the Awards tab from Road GP individual-standings.xlsx files and
// writes individualAwards into awards.json for each year.
//
// Usage:
//   node scripts/parse-road-gp-awards.js           # process all years
//   node scripts/parse-road-gp-awards.js 2025       # process one year
//   node scripts/parse-road-gp-awards.js --dry-run  # print output only

import XLSX from 'xlsx';
import fs from 'fs';
import path from 'path';

// ─── Mappings ───────────────────────────────────────────────────────────────

const CLUB_MAP = {
  Blackpool: 'blackpool',
  Lytham: 'lytham',
  Preston: 'preston',
  Chorley: 'chorley',
  'Red Rose': 'red-rose',
  Wesham: 'wesham',
  Thornton: 'thornton',
};

// Maps spreadsheet category labels to individualCategories IDs in config.json.
// Note: 'sen-female' and 'sen-male' are generated here but not yet in the
// default config — add them to each year's road-gp/config.json if needed.
const LABEL_TO_CATEGORY = {
  'Junior Female': 'jun-female',
  'Junior Male': 'jun-male',
  'Senior Lady': 'sen-female',
  'Senior Man': 'sen-male',
  FV35: 'v35-female',
  V40: 'v40-male',
  FV40: 'v40-female',
  V45: 'v45-male',
  FV45: 'v45-female',
  V50: 'v50-male',
  FV50: 'v50-female',
  V55: 'v55-male',
  FV55: 'v55-female',
  V60: 'v60-male',
  FV60: 'v60-female',
  V65: 'v65-male',
  FV65: 'v65-female',
  V70: 'v70-male',
  FV70: 'v70-female',
  V75: 'v75-male',
  FV75: 'v75-female',
  V80: 'v80-male',
  FV80: 'v80-female',
  V85: 'v85-male',
  FV85: 'v85-female',
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function resolveClub(name) {
  if (!name) return undefined;
  const s = String(name).trim();
  return CLUB_MAP[s] || s.toLowerCase().replace(/\s+/g, '-') || undefined;
}

function formatName(first, last) {
  const f = String(first ?? '').trim();
  const l = String(last ?? '').trim();
  if (!f || !l) return null;
  return `${f[0]}. ${l}`;
}

function isCategoryLabel(val) {
  return typeof val === 'string' && LABEL_TO_CATEGORY[val.trim()] != null;
}

function isNumberId(val) {
  return typeof val === 'number' && val > 0;
}

function loadJson(filePath) {
  const text = fs.readFileSync(filePath, 'utf8').replace(/^﻿/, '');
  return JSON.parse(text);
}

function loadRunnerLookup(year, series) {
  const p = path.join('src', 'data', year, series, 'runners.json');
  if (!fs.existsSync(p)) return {};
  return Object.fromEntries(loadJson(p).map(r => [r.id, r]));
}

// ─── Core parser ─────────────────────────────────────────────────────────────

function parseAwardsSheet(rows, runnerLookup) {
  const byCategory = {};

  function addAward(catId, position, runnerId, first, last, clubFromSheet) {
    const name = formatName(first, last);
    if (!name) return;

    const runnerClub = runnerId ? runnerLookup[runnerId]?.club : undefined;
    const club = runnerClub ?? resolveClub(clubFromSheet);

    const award = { position, name };
    if (club) award.club = club;
    if (runnerId) award.seriesRunnerId = runnerId;

    (byCategory[catId] ??= []).push(award);
  }

  // ── Section 1: top overall ladies / men (rows 3 onward until first blank) ──
  // Row layout: [runnerId, first, last, ageCat, club, races, pts, agePts, null,
  //              runnerId, first, last, ageCat, club, races, pts, agePts]
  let i = 3;
  while (i < rows.length) {
    const row = rows[i];
    if (!row || row.length === 0 || !isNumberId(row[0])) break;

    const pos = i - 2; // 1-based position

    // Ladies (cols 0-7)
    if (isNumberId(row[0])) {
      addAward('female', pos, row[0], row[1], row[2], row[4]);
    }
    // Men (cols 9-16)
    if (isNumberId(row[9])) {
      addAward('male', pos, row[9], row[10], row[11], row[13]);
    }
    i++;
  }

  // ── Section 2: per-category awards ──────────────────────────────────────────
  // Skip blank rows and section header ("Further Awards" / "Next in Category")
  while (i < rows.length) {
    const row = rows[i];
    if (!row || row.length === 0) { i++; continue; }
    const c1 = String(row[1] ?? '').trim();
    if (c1 === 'Further Awards' || c1 === 'Next in Category') { i++; break; }
    const c0 = String(row[0] ?? '').trim();
    if (c0 === 'Further Awards' || c0 === 'Next in Category') { i++; break; }
    break;
  }

  while (i < rows.length) {
    const row = rows[i];
    if (!row || row.length === 0) { i++; continue; }

    // Detect category label at col 1 or col 0 (ladies) and col 10 or col 9 (men)
    const c0 = String(row[0] ?? '').trim();
    const c1 = String(row[1] ?? '').trim();
    const c9 = String(row[9] ?? '').trim();
    const c10 = String(row[10] ?? '').trim();

    const leftLabel = isCategoryLabel(c1) ? c1 : isCategoryLabel(c0) ? c0 : null;
    const rightLabel = isCategoryLabel(c10) ? c10 : isCategoryLabel(c9) ? c9 : null;

    if (!leftLabel && !rightLabel) { i++; continue; }

    // ── Format detection ──
    // 2017: category header row also contains position 1 runner data (runner_id at col 2)
    // 2018+: category header row is a label only; data follows on the next two rows
    const is2017Style = isNumberId(row[2]);

    if (is2017Style) {
      // Header row = position 1
      if (leftLabel && isNumberId(row[2])) {
        addAward(LABEL_TO_CATEGORY[leftLabel], 1, row[2], row[3], row[4], null);
      }
      if (rightLabel && isNumberId(row[11])) {
        addAward(LABEL_TO_CATEGORY[rightLabel], 1, row[11], row[12], row[13], null);
      }

      // Advance to position 2 row (skip blanks)
      i++;
      while (i < rows.length && (!rows[i] || rows[i].length === 0)) i++;
      if (i < rows.length) {
        const r2 = rows[i];
        if (leftLabel && isNumberId(r2[2])) {
          addAward(LABEL_TO_CATEGORY[leftLabel], 2, r2[2], r2[3], r2[4], null);
        }
        if (rightLabel && isNumberId(r2[11])) {
          addAward(LABEL_TO_CATEGORY[rightLabel], 2, r2[11], r2[12], r2[13], null);
        }
        i++;
      }
    } else {
      // 2018+ style: gather the next two non-blank, non-header rows as pos 1 and pos 2.
      // Both regular categories and Juniors use the same column layout:
      //   ladies: count(1), runnerId(2), first(3), last(4)
      //   men:    count(10), runnerId(11), first(12), last(13)
      i++;
      let pos = 1;
      while (i < rows.length && pos <= 2) {
        const nr = rows[i];
        if (!nr || nr.length === 0) { i++; continue; }

        // Stop if we've hit the next category header
        const nc0 = String(nr[0] ?? '').trim();
        const nc1 = String(nr[1] ?? '').trim();
        if (isCategoryLabel(nc0) || isCategoryLabel(nc1)) break;

        if (leftLabel && isNumberId(nr[2])) {
          addAward(LABEL_TO_CATEGORY[leftLabel], pos, nr[2], nr[3], nr[4], null);
        }
        if (rightLabel && isNumberId(nr[11])) {
          addAward(LABEL_TO_CATEGORY[rightLabel], pos, nr[11], nr[12], nr[13], null);
        }
        pos++;
        i++;
      }
    }
  }

  // Convert to sorted array matching config individualCategories order
  const categoryOrder = [
    'female', 'male',
    'jun-female', 'jun-male',
    'sen-female', 'sen-male',
    'v35-female',
    'v40-female', 'v40-male',
    'v45-female', 'v45-male',
    'v50-female', 'v50-male',
    'v55-female', 'v55-male',
    'v60-female', 'v60-male',
    'v65-female', 'v65-male',
    'v70-female', 'v70-male',
    'v75-female', 'v75-male',
    'v80-female', 'v80-male',
    'v85-female', 'v85-male',
  ];

  return categoryOrder
    .filter(id => byCategory[id]?.length > 0)
    .map(id => ({ category: id, awards: byCategory[id] }));
}

// ─── Per-year processing ──────────────────────────────────────────────────────

function processYear(year, dryRun) {
  const xlsxPath = path.join('src', 'data', year, 'road-gp', 'individual-standings.xlsx');
  if (!fs.existsSync(xlsxPath)) return;

  const wb = XLSX.readFile(xlsxPath);
  const sheet = wb.Sheets['Awards'];
  if (!sheet) {
    console.warn(`[${year}] No Awards sheet found — skipping`);
    return;
  }

  const rows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: null });
  const runnerLookup = loadRunnerLookup(year, 'road-gp');
  const individualAwards = parseAwardsSheet(rows, runnerLookup);

  const awardsPath = path.join('src', 'data', year, 'road-gp', 'awards.json');
  let existing = { teamAwards: [] };
  if (fs.existsSync(awardsPath)) {
    existing = loadJson(awardsPath);
  }

  const output = {
    ...existing,
    individualAwards,
  };

  const json = JSON.stringify(output, null, 2);

  if (dryRun) {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`[${year}] ${awardsPath}`);
    console.log(json);
  } else {
    fs.writeFileSync(awardsPath, json, 'utf8');
    const count = individualAwards.reduce((n, c) => n + c.awards.length, 0);
    console.log(`[${year}] wrote ${count} awards across ${individualAwards.length} categories → ${awardsPath}`);
  }
}

// ─── Entry point ─────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const yearArg = args.find(a => /^\d{4}$/.test(a));

const allYears = fs
  .readdirSync(path.join('src', 'data'))
  .filter(d => /^\d{4}$/.test(d))
  .sort();

const years = yearArg ? [yearArg] : allYears;

for (const year of years) {
  processYear(year, dryRun);
}
