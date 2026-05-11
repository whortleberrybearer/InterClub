---
name: fell-results-processor
description: Process fell championship result PDFs and restructure individual standings JSON. Use this skill whenever you need to extract runner data from a fell race PDF, validate that the correct number of runners are present, or restructure standings to match the PDF source. The skill handles page layout variations and creates properly formatted standings with correct point calculations and counting race flags.
compatibility: pdftotext command-line tool (poppler-utils)
---

# Processing Fell Championship Results from PDF

This skill extracts runner data from fell championship PDFs (which are the source of truth) and restructures them into the InterClub standings JSON format, with full validation of runner counts and data integrity.

## Overview

The workflow is:
1. Extract text from the PDF file (page ranges may vary by year)
2. Parse runner data from individual standings sections by category
3. Calculate points based on finish position (100 to 1st place, scaled down)
4. Determine which races count toward the season total (typically top 3 of 4)
5. Restructure data into `individual-standings.json` format
6. Validate that all runners are accounted for
7. Output corrected files and validation report

## Step 1: Extract Text from PDF

Use `pdftotext` to extract the individual standings section. The section location varies by year, but typically starts around page 5-6 and contains multiple category tables.

```bash
pdftotext -f <start_page> -l <end_page> <pdf_path> /tmp/standings.txt
```

**Find the section by:**
- Looking for a header like "Individual Standings" or "Season Individual Standings"
- Identifying category tables (Men, Women, Men V40, Men V50, etc.)
- Stopping when you reach a section header for something else (awards, team results, etc.)

After extraction, scan the text to confirm all expected categories are present.

## Step 2: Parse Runner Data by Category

The PDF is organized into category sections. Each section has:
- **Overall category**: All runners of a sex ranked together (Men, Women)
- **Age-specific categories**: Filtered rankings by age band (V40, V50, V60, etc.)

### Category Structure

**Men overall (sen-m):** All male runners ranked 1–N, with `ageCategory` field showing SEN/V40/V50/V60/V70

**Women overall (sen-f):** All female runners ranked 1–N, with `ageCategory` field showing F/F40/F50/F60

**Age-specific sections** (m40, m50, m60, f40, f50): Detailed rankings within each age group. Note: V60 females are **merged into f50**, not a separate f60 category.

### Parsing Each Runner Entry

Extract from each category table:
- **Position**: Overall rank within that category (1, 2, 3, ...)
- **Name**: Exact spelling from PDF
- **Club**: Club ID (e.g., "chorley", "wesham", "red-rose")
- **Sex**: M or F
- **Age category**: SEN, V40, V50, V60, V70 (or F, F40, F50, F60 for females)
- **Total points**: Sum of counting race points
- **Race results**: Position in each race (extract from PDF's results columns, or cross-reference with individual race CSVs)

## Step 3: Calculate Points and Counting Races

### Point Calculation

Points are assigned based on finish position within each race. For a race with N finishers:
- 1st place: 100 points
- 2nd place: 99 points
- 3rd place: 98 points
- ...
- Nth place: (101 - N) points

Minimum 1 point for any finisher.

### Determine Counting Races

- Check `config.json` for `maxCountingRaces` (typically 3)
- For each runner, identify their top N race scores
- Mark those as `"counting": true`, others as `"counting": false`
- Recalculate `total` as the sum of counting races only

**Example:** Runner has scores of [100, 98, 95, 80] across 4 races with `maxCountingRaces: 3`. The top 3 are [100, 98, 95] (total: 293), and the 80 is marked as non-counting.

## Step 4: Structure Individual Standings JSON

The output file is `src/data/{year}/fell/individual-standings.json`.

```json
{
  "provisional": false,
  "races": ["race-id-1", "race-id-2", "race-id-3", "race-id-4"],
  "categories": [
    {
      "category": "sen-m",
      "runners": [
        {
          "position": 1,
          "name": "Full Name",
          "club": "club-id",
          "sex": "M",
          "ageCategory": "SEN",
          "total": 295,
          "results": {
            "race-id-1": {"points": 100, "counting": true},
            "race-id-2": {"points": 98, "counting": true},
            "race-id-3": {"points": 97, "counting": true},
            "race-id-4": {"points": 94, "counting": false}
          }
        }
      ]
    },
    {
      "category": "sen-f",
      "runners": [...]
    },
    {
      "category": "m40",
      "runners": [...]
    },
    {
      "category": "m50",
      "runners": [...]
    },
    {
      "category": "m60",
      "runners": [...]
    },
    {
      "category": "f40",
      "runners": [...]
    },
    {
      "category": "f50",
      "runners": [...]
    }
  ]
}
```

**Key points:**
- `sen-m` and `sen-f` include ALL runners of that sex, with `ageCategory` distinguishing them
- Age-specific categories (m40, m50, m60, f40, f50) contain ranked subsets of the overall category
- `f60` category does NOT exist; V60 females are in the `f50` category
- `results` object maps race ID to points + counting flag; only races the runner entered are present
- `total` must equal the sum of counting race points

## Step 5: Validate Runner Counts

Perform these validation checks:

### Check 1: All runners accounted for
- Count runners in sen-m overall category
- Count total runners in all age-specific male categories (m40 + m50 + m60)
- Verify no gaps (some runners should appear in both overall and age-specific)

### Check 2: No duplicates
- Scan for duplicate names within each category (case-insensitive)
- Flag any runner appearing multiple times in sen-m

### Check 3: Category consistency
- Verify sen-f includes exactly the runners from f40 + f50
- Verify all sen-m runners appear in exactly one age-specific category
- Confirm all V60 females are in f50, not in a separate f60

### Check 4: Required fields
- Every runner entry must have: position, name, club, sex, ageCategory, total, results
- results object must have at least one race entry

### Check 5: Point totals
- Recalculate `total` as sum of races marked `counting: true`
- Flag any mismatches

### Check 6: Counting races
- Verify runners with 1–3 races have all marked as `counting: true`
- Verify runners with 4+ races have exactly N races marked true (where N = maxCountingRaces)
- Flag any runners with extra or missing counting races

## Output Format

**Corrected files:**
- `src/data/{year}/fell/individual-standings.json` — restructured standings matching PDF
- Any corrected individual race CSVs if position/club data was fixed (e.g., `results/{race-id}.csv`)

**Validation report:** Plain text summary including:
- Total runners extracted by sex (e.g., "59 male, 25 female")
- Breakdown by age category
- Any validation failures with specific runner names or categories affected
- Confirmation that all checks passed or list of issues to fix

**Example report:**
```
=== Fell Championship 2023 Results Processing ===

Total runners: 84 (59 M, 25 F)

Male breakdown:
  SEN: 15
  V40: 9
  V50: 23
  V60: 9
  V70: 2

Female breakdown:
  F: 6
  F40: 6
  F50: 13 (includes 3 V60)

Races included: wardle-skyline, aggies-staircase, beetham-sports, golf-ball

Validation results:
  ✓ All 59 male runners accounted for
  ✓ All 25 female runners accounted for
  ✓ No duplicates found
  ✓ Category consistency verified (f60 merged into f50)
  ✓ Point totals verified
  ✓ Counting races verified (3 of 4 races count)

Status: PASS
```

## Common Edge Cases

**Page layout variations:** The PDF structure may shift between years. If extraction fails:
- Adjust the page range (`-f <start>` `-l <end>`)
- Look for section headers to identify where categories start/end
- Re-extract with corrected range and retry parsing

**Name formatting:** PDF may show "J. Smith" or "John Smith" inconsistently. Standardize to full names where possible; flag any ambiguities.

**Missing race data:** If a runner's results for a specific race are blank in the PDF, that race simply doesn't appear in their `results` object.

**Provisional vs. final:** Set `"provisional": false` for final results. Set to `true` if the PDF itself indicates provisional/unofficial status.
