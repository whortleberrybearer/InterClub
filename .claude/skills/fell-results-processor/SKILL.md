---
name: fell-results-processor
description: Process fell championship result PDFs and restructure all standings data (individual results CSVs, individual standings JSON, team results JSON, team standings JSON, and awards JSON). Use this skill whenever you need to extract runner data from fell championship PDFs, validate data across multiple file types, correct position/ic_position mappings in race CSVs, or restructure standings to match PDF source data. The skill handles page layout variations, calculates points correctly, validates runner counts and team compositions, and produces comprehensive validation reports.
compatibility: pdftotext command-line tool (poppler-utils)
---

# Processing Fell Championship Results from PDF

This skill extracts runner data from fell championship PDFs (which are the source of truth) and restructures all InterClub standings data types (individual race results, individual standings, team results, team standings, and awards) with full validation and data integrity checks.

## Overview

The complete workflow handles:
1. **Individual race results CSVs** — Extract runner data and validate position/ic_position mapping
2. **Individual standings JSON** — Parse category sections and structure comprehensive season data
3. **Team results JSON** — Parse team scoring by category and validate team compositions
4. **Team standings JSON** — Build season-long standings with running point totals
5. **Awards JSON** — Extract and validate individual and team award winners

The PDF is the source of truth. All output files are restructured to match the PDF exactly, with comprehensive validation at each step.

---

## Part A: Individual Race Results CSVs

### Understanding the Data

Each fell race produces a CSV file (`results/{race-id}.csv`) with runner results. The CSV has two position columns that serve different purposes:

- **position**: The runner's finish position in that specific race (1st finisher = 1, 2nd = 2, etc.)
- **ic_position**: The runner's overall InterClub position across all races in the season (used for rankings)

The PDF provides two columns that map directly to these:

- PDF **"Pos."** column → CSV `position` (race finish position)
- PDF **"Overall"** column → CSV `ic_position` (InterClub overall position)

### Parsing Race Results from PDF

For each race section in the PDF:

1. **Extract the results table** with columns: Pos., Overall, Name, Club, Category, Sex, Time
2. **Map to CSV columns:**
   - PDF "Pos." column → `position`
   - PDF "Overall" column → `ic_position`
   - Name, Club, Category, Sex, Time → preserve exactly as shown
3. **Preserve all other fields** exactly as they appear: first_name, last_name, club, category, sex, time

### Validation Checks for CSVs

- **ic_position is sequential**: 1, 2, 3... with no gaps
- **No duplicates**: Each runner appears once
- **All required fields present**: position, ic_position, first_name, last_name, club, category, sex, time
- **Club IDs valid**: Match `clubs.json` for the year or "Guest" for non-members
- **Categories valid**: Match `config.json` age categories (SEN, V40, V50, V60, V70)
- **Sex is M or F**: Consistent with runner data
- **Time format valid**: HH:MM:SS or MM:SS

**Example CSV structure:**
```
position,ic_position,first_name,last_name,club,category,sex,time
19,1,Alek,Walker,wesham,V40,M,00:46:41
30,2,Darren,Fishwick,chorley,V50,M,00:48:22
31,3,Darren,McDermott,preston,V50,M,00:48:37
```

---

## Part B: Individual Standings JSON

### Understanding the Structure

The individual standings file (`individual-standings.json`) contains the season-long standings across all races. It's organized into two types of categories:

- **Overall categories** (sen-m, sen-f): All runners of a sex ranked together, with `ageCategory` field distinguishing sub-groups
- **Age-specific categories** (m40, m50, m60, f40, f50): Detailed rankings within each age group

### Parsing Standings from PDF

Extract the standings data exactly as it appears in the PDF document. The PDF shows the complete standings with all runner positions, point totals, and race results with counting flags already determined. **Use these values directly with no additional calculating or filtering applied.** The standings should match what is generated in the document exactly.

### Category Structure in JSON

**Overall categories include all runners of that sex with ageCategory distinguishing them:**

```json
{
  "category": "sen-m",
  "runners": [
    {
      "position": 1,
      "name": "Alek Walker",
      "club": "wesham",
      "sex": "M",
      "ageCategory": "SEN",
      "total": 296,
      "results": {
        "wardle-skyline": {"points": 100, "counting": true},
        "aggies-staircase": {"points": 92, "counting": true},
        "beetham-sports": {"points": 96, "counting": true},
        "golf-ball": {"points": 100, "counting": false}
      }
    }
  ]
}
```

**Age-specific categories contain ranked subsets:**

```json
{
  "category": "m40",
  "runners": [
    {
      "position": 1,
      "name": "David Cowburn",
      "club": "chorley",
      "sex": "M",
      "ageCategory": "V40",
      "total": 298,
      "results": {
        "wardle-skyline": {"points": 100, "counting": true},
        "aggies-staircase": {"points": 98, "counting": true},
        "beetham-sports": {"points": 100, "counting": true}
      }
    }
  ]
}
```

### Validation Checks for Individual Standings

- **All runners from PDF present**: No missing runners
- **No duplicates**: Each runner appears exactly once in sen-m/sen-f
- **Category consistency**: 
  - sen-f includes exactly the runners from f40 + f50
  - All sen-m runners appear in exactly one age-specific category (m40, m50, m60, m70)
- **Required fields on every runner**: position, name, club, sex, ageCategory, total, results
- **Results object** has at least one race entry, no nulls
- **Age categories valid**: SEN, V40, V50, V60, V70 for males; F, F40, F50, F60 for females
- **Data matches PDF exactly**: All values extracted directly from document with no modifications

---

## Part C: Team Results JSON

### Understanding Team Results

Team results files (`results/{race-id}-teams.json`) show how teams scored in each race by category. Each team category (Open, Ladies, V40, etc.) has a list of clubs with their scoring runners.

### Parsing Team Results from PDF

If the PDF includes a team results section for a race:

1. **Identify team categories** (from PDF section headers)
2. **For each category**, extract:
   - Club name and ID
   - Position (rank in that category)
   - Points awarded
   - Scorer count (number of runners that counted)
   - Scorer race positions (the finish positions in the race for each scoring runner)

3. **Build the JSON structure:**

```json
{
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1,
          "club": "wesham",
          "points": 7,
          "total": 175,
          "scorers": [
            {"position": 5},
            {"position": 8}
          ]
        }
      ]
    }
  ]
}
```

**Important:** Team results contain only race positions (finish order), not runner names. Extract positions directly from the PDF with no recalculation or inference of runner data.

### Validation Checks for Team Results

- **Category IDs match config.json**: All team categories in the file exist in `teamCategories`
- **Club IDs valid**: Match `clubs.json` for that year
- **Scorer count correct**: Matches `teamCategories[category].scorerCount`
- **Points assigned**: Non-zero for teams with full scorer count, 0 for incomplete teams
- **No duplicate clubs** in the same category
- **Data matches PDF exactly**: All values extracted directly from document with no modifications, calculations, or inference

---

## Part D: Team Standings JSON

### Understanding Team Standings

The team standings file (`team-standings.json`) shows season-long standings for each team category. It tracks each club's points race-by-race across the season.

### Building Team Standings

1. **Define the race order** — List all races in season order (e.g., wardle-skyline, aggies-staircase, beetham-sports, golf-ball)
2. **For each team category**, build standings:
   - Position (rank)
   - Club name and ID
   - Points array (one entry per race, null if not yet run)
   - Total (sum of points)
   - Optional tiebreaker (string, shown if non-null)

3. **JSON structure:**

```json
{
  "provisional": false,
  "races": ["wardle-skyline", "aggies-staircase", "beetham-sports", "golf-ball"],
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1,
          "club": "wesham",
          "points": [7, 8, 6, 7],
          "total": 28,
          "tiebreaker": null
        },
        {
          "position": 2,
          "club": "chorley",
          "points": [6, 6, 7, 8],
          "total": 27,
          "tiebreaker": null
        }
      ]
    }
  ]
}
```

### Race Shortnames (Optional)

In `races.json`, you can add a `shortName` field to each race for compact column headers:

```json
{
  "id": "wardle-skyline",
  "name": "Wardle Skyline",
  "shortName": "WRD"
}
```

If present, use this in the standings display; otherwise use the race ID.

### Validation Checks for Team Standings

- **All races included**: Each race in standings matches `races.json`
- **Race order correct**: Matches the order in races.json
- **All clubs represented**: Every club from clubs.json that fielded a team appears
- **Points array length**: Must equal number of races
- **Null vs points**: Races not yet run show null, completed races show numeric points
- **Points are valid**: Match the individual race team results
- **Totals calculated correctly**: Sum of non-null points
- **No duplicate clubs** in same category
- **Category IDs match** `teamCategories` in config.json
- **Provisional flag accurate**: true if any points are subject to change, false if final

---

## Part E: Awards JSON

### Understanding Awards

The awards file (`awards.json`) lists individual and team award winners for the season. This file belongs to the **previous year** since awards are announced the following season.

### Parsing Awards from PDF

If the PDF includes an awards section:

1. **Team awards** — One winner per team category
   - Category ID (e.g., "open", "ladies")
   - Winning club

2. **Individual awards** — Winners in each individual category
   - Category ID (e.g., "sen-m", "v40-f")
   - Position rank (1, 2, 3, etc. — gaps allowed)
   - Winner's name
   - Winner's club

**Important filtering rule:** Only include individual award winners marked with **"Trophy"** exactly. Exclude entries marked with "(Trophy)" (with parentheses) or blank/empty award indicators. These represent different award types and should not be included in the awards.json output.

3. **JSON structure:**

```json
{
  "teamAwards": [
    {"category": "open", "club": "wesham"},
    {"category": "ladies", "club": "red-rose"}
  ],
  "individualAwards": [
    {
      "category": "sen-m",
      "awards": [
        {
          "position": 1,
          "name": "L. Minns",
          "club": "blackpool"
        },
        {
          "position": 2,
          "name": "T. Guest",
          "club": "red-rose"
        }
      ]
    }
  ]
}
```

### Validation Checks for Awards

- **Team category IDs valid**: Match `teamCategories` in config.json
- **Individual category IDs valid**: Match `individualCategories` in config.json (if defined)
- **Club IDs valid**: Match `clubs.json`
- **Award positions unique** within each category (no two 1st places)
- **No missing required fields**: position, name, club required for individual awards
- **Data matches PDF exactly**: All values extracted directly from document with no modifications

---

## Data Validation Report Format

After processing all files, generate a comprehensive validation report:

```
=== Fell Championship 2023 Results Processing ===

SOURCE: 2023-fell-results.pdf
PROCESSED: [date]

INDIVIDUAL RACE RESULTS
  Files created: 4
  - wardle-skyline.csv: 25 finishers
  - aggies-staircase.csv: 51 finishers
  - beetham-sports.csv: 53 finishers
  - golf-ball.csv: 30 finishers
  Total unique runners: 84
  Validation: ✓ PASS

INDIVIDUAL STANDINGS
  Total runners: 84 (59 M, 25 F)
  Categories: sen-m, sen-f, m40, m50, m60, f40, f50
  
  Male breakdown:
    SEN: 15 runners
    V40: 9 runners
    V50: 23 runners
    V60: 9 runners
    V70: 2 runners
  
  Female breakdown:
    F: 6 runners
    F40: 6 runners
    F50: 13 runners (includes 3 V60)
  
  Validation checks:
    ✓ All runners accounted for
    ✓ No duplicates
    ✓ Category consistency verified
    ✓ Data matches PDF exactly
  
  Validation: ✓ PASS

TEAM RESULTS
  Races with team results: 4
  Team categories present: open, ladies, v40, v50, v60
  Total scoring clubs: 7
  
  Per-race validation:
    ✓ wardle-skyline: 5 categories, all clubs represented
    ✓ aggies-staircase: 5 categories, all clubs represented
    ✓ beetham-sports: 5 categories, all clubs represented
    ✓ golf-ball: 5 categories, all clubs represented
  
  Validation: ✓ PASS

TEAM STANDINGS
  Races included: 4
  Team categories: open, ladies, v40, v50, v60
  Clubs per category: 5–7
  
  Validation checks:
    ✓ All races represented
    ✓ All clubs accounted for
    ✓ Data matches PDF exactly
    ✓ No provisional standings
  
  Validation: ✓ PASS

AWARDS
  Team awards: 5 (one per category)
  Individual awards: 7 categories
  Total individual winners: 21
  
  Validation checks:
    ✓ All category IDs valid
    ✓ No duplicate award positions
    ✓ All club references valid
    ✓ seriesRunnerIds verified where present
  
  Validation: ✓ PASS

=== SUMMARY ===
Total validations run: 24
Passed: 24
Failed: 0
Status: ✓ ALL CHECKS PASSED

Files created/updated:
  - src/data/2023/fell/results/wardle-skyline.csv
  - src/data/2023/fell/results/aggies-staircase.csv
  - src/data/2023/fell/results/beetham-sports.csv
  - src/data/2023/fell/results/golf-ball.csv
  - src/data/2023/fell/individual-standings.json
  - src/data/2023/fell/results/wardle-skyline-teams.json
  - src/data/2023/fell/results/aggies-staircase-teams.json
  - src/data/2023/fell/results/beetham-sports-teams.json
  - src/data/2023/fell/results/golf-ball-teams.json
  - src/data/2023/fell/team-standings.json
  - src/data/2023/fell/awards.json (if present in PDF)
```

---

## Common Edge Cases and Troubleshooting

**Page layout variations** — PDF sections may shift between years:
- Adjust pdftotext page range (`-f <start>` `-l <end>`)
- Look for section headers to identify where each type of data starts/ends
- Re-extract with corrected range if needed

**Name formatting inconsistencies** — PDFs may show abbreviated or full names:
- Standardize to full names where possible
- Flag any ambiguities (multiple runners with same surname)
- Cross-reference with existing runner data

**Missing team results** — Not all races may have team results in the PDF:
- Only create team results files for races with team data
- Proceed with team standings if most races have team data
- Flag missing races in validation report

**Incomplete data** — Runners with no race results:
- Include in overall standings if they appear in the PDF
- Their results object will be sparse (only races entered)
- Mark their total as calculated from available races

**Award winners not in standings** — Sometimes award winners aren't runners:
- Include them in awards.json as-is
- Flag in validation report if they don't match any runner
- Leave seriesRunnerId absent if not found in registry
