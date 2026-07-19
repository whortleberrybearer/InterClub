---
name: merge-runners
description: Merge two or more duplicate global runner identities in src/data/runners.json into one (e.g. "Adam Smith" and "A Smith" turn out to be the same person). Use when the user asks to merge, combine, dedupe, or link duplicate runners, or reports that one person appears under multiple global runner ids.
---

# Merge Runners

Use this skill when the user identifies (or asks you to find) duplicate global runner identities that should be combined into one.

Announce: "Using merge-runners skill to combine duplicate runner identities."

## What it does

Every series-local `runners.json` entry (across all years, both `road-gp` and `fell`) that links via `runnerId` to one of the ids being merged away is repointed to the master id. The merged-away entries are then deleted from `src/data/runners.json`. Results CSVs, team JSON, awards, and standings files are untouched — they reference series-local ids, not global ids, so they keep working automatically.

The skill scripts are at `<skill_dir>/scripts/` where `<skill_dir>` is the base directory of this skill (shown when the skill was loaded).

## Step 1 — Establish the master id

If the user already gave you both a master id and the id(s) to merge, skip to Step 2.

Otherwise, search by name and ask the user to confirm:

```
<skill_dir>/scripts/merge-runners.ps1 -Search "<lastname>"
```

This lists matching global runners (id, name, club, sex, ageCategory, ageCategoryYear) without modifying anything.

Pick the most complete/canonical-looking entry as the likely master (e.g. full first name over an initial, more recent `ageCategoryYear`, more common club spelling) and propose it to the user via `AskUserQuestion` rather than deciding silently — merging is destructive to the losing id.

## Step 2 — Run the merge

```
<skill_dir>/scripts/merge-runners.ps1
  -MasterId    <id>
  -MergeIds    <id>[,<id>...]
  -ProjectRoot "<ProjectRoot>"
  [-DryRun]
```

Derive `ProjectRoot` with `git rev-parse --show-toplevel` if not already known.

Run with `-DryRun` first when the merge involves more than one MergeId, or when confidence in the match is anything less than certain. Review the printed master/merge-candidate details and the list of series-local links that would be repointed, then re-run without `-DryRun`.

## Step 3 — Reformat and verify

The script uses PowerShell's `ConvertTo-Json`, which rewrites touched files with 4-space indent instead of the repo's 2-space style. Reformat every file the script reported as touched (the global `src/data/runners.json` plus each listed series `runners.json`) back to 2-space indent, single space after `:`, and literal apostrophes before committing — `git diff --stat` should show only the entries that actually changed, not the whole file.

Then verify:
- `src/data/runners.json` no longer contains the merged-away id(s)
- The surviving master entry's `club`/`sex`/`ageCategory` still looks correct
- `npm test` still passes

## Common mistakes

- Picking the master id by which one has the lower id number rather than which name/club/category is most complete or most recent — prefer the more canonical-looking identity.
- Merging runners whose `sex` or `club` genuinely differ — that usually means they are different people, not a duplicate. Confirm with the user before merging if any field other than name spelling differs.
- Forgetting to reformat the JSON before committing, producing a multi-thousand-line noise diff.
