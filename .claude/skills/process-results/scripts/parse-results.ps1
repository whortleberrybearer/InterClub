<#
.SYNOPSIS
    Parses an InterClub results Excel file and generates the required data files.

.DESCRIPTION
    Reads the Excel file and generates:
      - Individual results CSV         (from "Positions" tab)
      - Team results JSON              (from "Team Scorers" + "Team Positions" tabs)
      - Updated team standings JSON    (from "Season Totals" tab)

    The script prompts for any parameters not supplied on the command line.

.PARAMETER ExcelFile
    Path to the Excel results file.

.PARAMETER RaceId
    Race ID as used in the site data (e.g. "blackpool", "red-rose").

.PARAMETER Year
    Series year (e.g. 2026).

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the parent of the scripts folder.

.PARAMETER Provisional
    When set, writes provisional file names and marks standings as provisional.

.PARAMETER DryRun
    Parse and validate everything but do not write any files.

.EXAMPLE
    .\scripts\parse-results.ps1 -ExcelFile "C:\Downloads\blackpool 2026.xlsx" -RaceId blackpool -Year 2026

.EXAMPLE
    .\scripts\parse-results.ps1 -Provisional -DryRun
#>

[CmdletBinding()]
param(
    [string]$ExcelFile,
    [string]$RaceId,
    [string]$Year,
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$Provisional,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ─── Helpers ──────────────────────────────────────────────────────────────────

function Prompt-Value {
    param([string]$Prompt, [string]$Default = "")
    if ($Default) {
        $val = Read-Host "$Prompt [$Default]"
        if (-not $val) { return $Default }
        return $val
    }
    do { $val = Read-Host $Prompt } while (-not $val)
    return $val
}

function Get-ClubId {
    param([string]$Name)
    switch -Wildcard ($Name.Trim().ToLower()) {
        "blackpool*" { return "blackpool" }
        "blackpool & fylde*" { return "blackpool-fylde" }   # 2006: Blackpool & Fylde AC
        "b.w.f*"     { return "blackpool" }   # 2015: B.W.F., B.W.F
        "bwf*"       { return "blackpool" }   # 2015/2009: BWF abbreviation
        "b'pool*"    { return "blackpool" }   # 2009: B'pool Wyre & Fylde
        "b&f*"       { return "blackpool-fylde" }   # 2006: B&F abbreviation (Blackpool & Fylde AC)
        "chorley*"   { return $script:chorleyClubId }
        "cac"        { return $script:chorleyClubId }   # 2009: CAC abbreviation
        "lytham*"    { return "lytham"    }
        "lsa*"       { return "lytham"    }   # 2009: LSA / LSA RR abbreviation
        "north fylde*" { return "north-fylde" }
        "nf"         { return "north-fylde" }   # 2006: NF abbreviation
        "preston*"   { return "preston"   }
        "ph"         { return "preston"   }   # 2009: PH abbreviation
        "red rose*"  { return "red-rose"  }
        "red-rose*"  { return "red-rose"  }   # 2015: hyphenated variant
        "rr"         { return "red-rose"  }   # 2009: RR abbreviation
        "rrrr*"      { return "red-rose"  }   # 2009: RRRR in Tables
        "thornton*"  { return "thornton"  }
        "tc"         { return "thornton"  }   # 2009: TC abbreviation
        "wesham*"    { return "wesham"    }
        "wrr"        { return "wesham"    }   # 2009: WRR abbreviation
        "guest*"     { return "Guest"     }
    }
    return $null
}

# Populated from config after it is loaded - maps Excel display names -> config category IDs
$script:categoryMap = @{}

# Resolved after Year is known: pre-2012 results use "chorley-ac"; 2012+ use "chorley"
$script:chorleyClubId = "chorley"

function Build-CategoryMap {
    param($teamCategories)

    $map = @{}

    foreach ($cat in $teamCategories) {
        $lname = $cat.name.ToLower()

        # Exact config name always resolves to its own ID
        $map[$lname] = $cat.id

        # Pattern aliases so Excel display names resolve regardless of config naming convention
        if ($lname -match '\bopen\b') {
            $map["open"]  = $cat.id
            $map["team"]  = $cat.id
        }
        if ($lname -match 'ladies' -and $lname -notmatch 'vet') {
            $map["ladies"] = $cat.id
            $map["women"]  = $cat.id   # 2015 Tables uses "WOMEN" for the ladies category
        }
        if ($lname -match '\bwomen\b' -and $lname -notmatch 'vet') {
            $map["women"] = $cat.id   # 2009: team category named "Women"
        }
        # Female-vets category: config may call it "FV40", "Lady Vets", etc.
        if ($lname -match '(fv.?40|lady.?vet|female.?vet)' -and $lname -notmatch '(50|60)') {
            $map["fv40"]       = $cat.id
            $map["lady vets"]  = $cat.id
        }
        if ($lname -match 'vets?' -and $lname -notmatch '(50|60|lady|female|fv)') {
            $map["vets"] = $cat.id
        }
        if ($lname -match '50') {
            $map["vet 50s"] = $cat.id
            $map["vet-50"]  = $cat.id   # 2015: "VET-50"
            $map["vet50"]   = $cat.id   # 2009 Tables: "VET50"
            $map["v50"]     = $cat.id   # 2009 Vets sheet section label
        }
        if ($lname -match '60') {
            $map["vet 60s"] = $cat.id
            $map["vet-60"]  = $cat.id   # 2015: "VET-60"
            $map["vet60"]   = $cat.id   # 2009 Tables: "VET60"
            $map["v60"]     = $cat.id   # 2009 Vets sheet section label
        }
    }

    return $map
}

function Get-TeamCategoryId {
    param([string]$Name)
    $key = $Name.Trim().ToLower()
    if ($script:categoryMap.ContainsKey($key)) { return $script:categoryMap[$key] }
    return $null
}

# Derives sex from a 2015-style category string (M, M-40, JM, F, F-40, JW, etc.)
function Get-Sex2015 {
    param([string]$Cat)
    $u = $Cat.Trim().ToUpper()
    if ($u -eq "JM" -or $u -match '^M') { return "M" }
    if ($u -eq "JW" -or $u -match '^F') { return "F" }
    return ""
}

# Converts a 2015-style category to the site's standard format.
# Already-normalised values (SEN, V40, etc.) pass through unchanged.
function Normalize-Category2015 {
    param([string]$Cat)
    switch -Regex ($Cat.Trim()) {
        '^(?i)(JM|JW|M|F)$'     { return "SEN" }
        '^(?i)[MF]-?(\d+)$'     { return "V$($Matches[1])" }
        default                  { return $Cat }
    }
}

# ─── Sheet parsers ────────────────────────────────────────────────────────────

function Parse-Positions {
    param($Sheet)

    $totalRows = $Sheet.UsedRange.Rows.Count
    $totalCols = $Sheet.UsedRange.Columns.Count

    # Find the header row by scanning for a row that contains both a position and a name/surname column header.
    # This works regardless of how many leading columns the format has.
    $headerRow = -1
    $script:colMap = @{ RaceNum = 1; Pos = 2; IC = 3; First = 9; Last = 10; Cat = 11; Sex = 12; Club = 14; Time = 15 }
    $script:catCols = @{}   # category_id -> column_number (for multiple category columns)

    for ($hr = 1; $hr -le [Math]::Min(20, $totalRows); $hr++) {
        $detected = @{ CatMulti = @{} }
        for ($c = 1; $c -le $totalCols; $c++) {
            $h = $Sheet.Cells.Item($hr, $c).Text.Trim().ToLower()
            $hOrig = $Sheet.Cells.Item($hr, $c).Text.Trim()
            # First-occurrence-wins for all fields
            switch -Wildcard ($h) {
                "runner*"       { if (-not $detected["RaceNum"]) { $detected["RaceNum"] = $c } }
                "bib*"          { if (-not $detected["RaceNum"]) { $detected["RaceNum"] = $c } }
                "posn"          { if (-not $detected["Pos"])     { $detected["Pos"]     = $c } }
                "pos"           { if (-not $detected["Pos"])     { $detected["Pos"]     = $c } }
                "position"      { if (-not $detected["Pos"])     { $detected["Pos"]     = $c } }
                "ic"            { if (-not $detected["IC"])      { $detected["IC"]      = $c } }
                "ic pos*"       { if (-not $detected["IC"])      { $detected["IC"]      = $c } }
                "name"          { if (-not $detected["First"])   { $detected["First"]   = $c } }
                "first*"        { if (-not $detected["First"])   { $detected["First"]   = $c } }
                "forename*"     { if (-not $detected["First"])   { $detected["First"]   = $c } }
                "christian*"    { if (-not $detected["First"])   { $detected["First"]   = $c } }
                "given*"        { if (-not $detected["First"])   { $detected["First"]   = $c } }
                "surname*"      { if (-not $detected["Last"])    { $detected["Last"]    = $c } }
                "last name*"    { if (-not $detected["Last"])    { $detected["Last"]    = $c } }
                "family*"       { if (-not $detected["Last"])    { $detected["Last"]    = $c } }
                "cat_*"         { $detected["CatMulti"][$h] = $c }
                "cat*"          { if (-not $detected["Cat"])     { $detected["Cat"]     = $c } }
                "class*"        { if (-not $detected["Cat"])     { $detected["Cat"]     = $c } }
                "sex"           { if (-not $detected["Sex"])     { $detected["Sex"]     = $c } }
                "m/f"           { if (-not $detected["Sex"])     { $detected["Sex"]     = $c } }
                "gender*"       { if (-not $detected["Sex"])     { $detected["Sex"]     = $c } }
                "club"          { if (-not $detected["Club"])    { $detected["Club"]    = $c } }
                "team"          { if (-not $detected["Club"])    { $detected["Club"]    = $c } }
                "time"          { if (-not $detected["Time"])    { $detected["Time"]    = $c } }
            }
            # Detect common team category column headers and map to category IDs
            if (-not $detected["Cat"]) {
                $catId = switch -Regex ($h) {
                    '^(open|team)$'                           { "open" }
                    '^(lady|ladies?|women?|female)$'          { "ladies" }
                    '^vet(?:eran)?s?$'                        { "vets" }
                    '^(?:lady|female)[-\s]?vet(?:eran)?s?$'   { "lady-vets" }
                    '^f[-\s]?v[-\s]?40|fv40$'                 { "lady-vets" }
                    '^v[-\s]?50|vet[-\s]?50s?$'               { "v50" }
                    '^v[-\s]?60|vet[-\s]?60s?$'               { "v60" }
                    default                                    { $null }
                }
                if ($catId) {
                    $detected["CatMulti"][$catId] = $c
                }
            }
        }
        # Require at least Pos + one of Last/Time to confirm this is the results header row
        if ($detected["Pos"] -and ($detected["Last"] -or $detected["Time"])) {
            $headerRow = $hr
            if ($detected["RaceNum"]) { $script:colMap["RaceNum"] = $detected["RaceNum"] }
            if ($detected["Pos"])     { $script:colMap["Pos"]     = $detected["Pos"]     }
            if ($detected["IC"])      { $script:colMap["IC"]      = $detected["IC"]      }
            if ($detected["First"])   { $script:colMap["First"]   = $detected["First"]   }
            if ($detected["Last"])    { $script:colMap["Last"]    = $detected["Last"]    }
            if ($detected["Cat"])     { $script:colMap["Cat"]     = $detected["Cat"]     }
            if ($detected["Sex"])     { $script:colMap["Sex"]     = $detected["Sex"]     }
            if ($detected["Club"])    { $script:colMap["Club"]    = $detected["Club"]    }
            if ($detected["Time"])    { $script:colMap["Time"]    = $detected["Time"]    }
            # Store multiple category columns (cat_open, cat_ladies, etc.)
            if ($detected["CatMulti"]) {
                $script:catCols = $detected["CatMulti"]
            }
            break
        }
    }

    # 2015 format: last-name column has no header — infer it as First+1 when header is blank
    if ($detected["First"] -and -not $detected["Last"]) {
        $nextColHeader = $Sheet.Cells.Item($headerRow, $detected["First"] + 1).Text.Trim()
        if (-not $nextColHeader) {
            $detected["Last"] = $detected["First"] + 1
            if ($detected["Last"]) { $script:colMap["Last"] = $detected["Last"] }
        }
    }

    # When RaceNum was not explicitly detected, use sentinel 0 so it is not
    # accidentally read from the wrong column (e.g. the position column in 2015).
    if (-not $detected["RaceNum"]) { $script:colMap["RaceNum"] = 0 }

    $catColsDesc = if ($script:catCols.Count -gt 0) { " CatCols: $($script:catCols.Keys -join ',')" } else { "" }
    Write-Host "  Header row: $headerRow | Cols: RaceNum=$($script:colMap['RaceNum']) Pos=$($script:colMap['Pos']) IC=$($script:colMap['IC']) First=$($script:colMap['First']) Last=$($script:colMap['Last']) Cat=$($script:colMap['Cat']) Sex=$($script:colMap['Sex']) Club=$($script:colMap['Club']) Time=$($script:colMap['Time'])$catColsDesc" -ForegroundColor DarkGray

    # Data starts at the row after the header; fall back to scanning col 1 if no header found
    if ($headerRow -gt 0) {
        $script:dataStartRow = $headerRow + 1
        # Skip any blank rows between header and first data row
        while ($script:dataStartRow -le $totalRows) {
            $testVal = $Sheet.Cells.Item($script:dataStartRow, $script:colMap["Pos"]).Text.Trim()
            if ($testVal -match '^\d+$') { break }
            $script:dataStartRow++
        }
    } else {
        $script:dataStartRow = -1
        for ($r = 2; $r -le [Math]::Min(20, $totalRows); $r++) {
            if ($Sheet.Cells.Item($r, 1).Text -match '^\d+$') { $script:dataStartRow = $r; break }
        }
    }
    if ($script:dataStartRow -eq -1 -or $script:dataStartRow -gt $totalRows) {
        throw "Could not find first data row in Positions sheet"
    }

    for ($r = $script:dataStartRow; $r -le $totalRows; $r++) {
        $pos = $Sheet.Cells.Item($r, $colMap["Pos"]).Text.Trim()
        if ($pos -notmatch '^\d+$') { continue }   # skip blank / non-runner rows

        $raceNum = if ($colMap["RaceNum"] -gt 0) { $Sheet.Cells.Item($r, $colMap["RaceNum"]).Text.Trim() } else { "" }
        $icPos   = $Sheet.Cells.Item($r, $colMap["IC"]).Text.Trim()
        $first   = $Sheet.Cells.Item($r, $colMap["First"]).Text.Trim()
        $last    = $Sheet.Cells.Item($r, $colMap["Last"]).Text.Trim()
        $cat     = $Sheet.Cells.Item($r, $colMap["Cat"]).Text.Trim()
        $sex     = $Sheet.Cells.Item($r, $colMap["Sex"]).Text.Trim()
        $club    = $Sheet.Cells.Item($r, $colMap["Club"]).Text.Trim()
        $time    = $Sheet.Cells.Item($r, $colMap["Time"]).Text.Trim()

        # Extract multiple category positions (from detected category columns)
        $catPositions = @{}
        foreach ($catId in $script:catCols.Keys) {
            $catValue = $Sheet.Cells.Item($r, $script:catCols[$catId]).Text.Trim()
            $catPositions[$catId] = if ($catValue -match '^\d+$') { [int]$catValue } else { $null }
        }

        # 2015 format: sex column absent — derive from category prefix (M/F/JM/JW)
        if ($sex -eq "" -and $cat -ne "") { $sex = Get-Sex2015 $cat }
        # 2015 format: category uses M/M-40/F/F-40 notation — convert to SEN/V40 etc.
        if ($cat -ne "") { $cat = Normalize-Category2015 $cat }

        $clubId = Get-ClubId $club
        if ($null -eq $clubId) {
            Write-Warning "Row ${r}: unknown club '$club' - treating as Guest"
            $clubId = "Guest"
        }

        Write-Output ([PSCustomObject]@{
            ExcelRow = $r
            Position = [int]$pos
            IcPos    = if ($icPos -match '^\d+$') { [int]$icPos } else { $null }
            RaceNum  = if ($raceNum -match '^\d+$') { [int]$raceNum } else { $null }
            First    = $first
            Last     = $last
            Club     = $clubId
            Category = $cat
            Sex      = $sex
            Time     = $time
            CategoryPositions = $catPositions
        })
    }
}

function Parse-TeamScorers {
    param($Sheet)

    # Header row: club name headers in columns 3+ (name column of each pair, pos column is one to the left)
    # Data rows: [scorer#][category?][pos1][name1][pos2][name2]...
    # Header row may not be row 1 — scan up to row 15 to find it.

    $totalCols = $Sheet.UsedRange.Columns.Count
    $totalRows = $Sheet.UsedRange.Rows.Count

    # Detect club columns — find first row with 2+ club name headers
    $headerRow = -1
    $clubCols  = [ordered]@{}   # club_name -> { PosCol; NameCol }
    for ($hr = 1; $hr -le [Math]::Min(15, $totalRows); $hr++) {
        $found = [ordered]@{}
        for ($c = 3; $c -le $totalCols; $c++) {
            $header = $Sheet.Cells.Item($hr, $c).Text.Trim()
            if ($header -and (Get-ClubId $header)) {
                $found[$header] = [PSCustomObject]@{ PosCol = $c - 1; NameCol = $c }
            }
        }
        if ($found.Count -ge 2) {
            $headerRow = $hr
            $clubCols  = $found
            break
        }
    }
    if ($clubCols.Count -eq 0) { throw "Could not detect club columns in Team Scorers sheet" }
    Write-Host "  Team Scorers header row: $headerRow  ($($clubCols.Count) clubs)" -ForegroundColor DarkGray

    $data = @{}       # category_id -> club_name -> List[PSCustomObject]
    $currentCat = $null

    for ($r = $headerRow + 1; $r -le $totalRows; $r++) {
        $scorerNum = $Sheet.Cells.Item($r, 1).Text.Trim()
        $catName   = $Sheet.Cells.Item($r, 2).Text.Trim()

        if ($catName) {
            $catId = Get-TeamCategoryId $catName
            if ($catId) {
                $currentCat = $catId
                $data[$catId] = @{}
                foreach ($cn in $clubCols.Keys) { $data[$catId][$cn] = [System.Collections.Generic.List[PSCustomObject]]@() }
            }
        }

        if (-not $currentCat) { continue }
        if ($scorerNum -notmatch '^\d+$') { continue }

        foreach ($clubName in $clubCols.Keys) {
            $cols       = $clubCols[$clubName]
            $scorerPos  = $Sheet.Cells.Item($r, $cols.PosCol).Text.Trim()
            $scorerName = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()

            if (-not $scorerPos -or $scorerPos -notmatch '^\d+$') { continue }
            if ($scorerName -ieq "Incomplete Team" -or -not $scorerName) { continue }

            $data[$currentCat][$clubName].Add([PSCustomObject]@{
                Position = [int]$scorerPos
                Name     = $scorerName
            })
        }
    }

    return $data
}

function Parse-TeamPositions {
    param($Sheet)

    # Layout: two category tables side by side
    #   Left:  cols 1 (club name) + 2 (total)
    #   Right: cols 4 (club name) + 5 (total)
    # Category header rows have the category name in col 1 and/or col 4 with empty value cols.

    $totalRows = $Sheet.UsedRange.Rows.Count
    $data = @{}   # category_id -> ordered list of { Club; Total }

    $currentLeft  = $null
    $currentRight = $null

    for ($r = 1; $r -le $totalRows; $r++) {
        $c1 = $Sheet.Cells.Item($r, 1).Text.Trim()
        $c2 = $Sheet.Cells.Item($r, 2).Text.Trim()
        $c4 = $Sheet.Cells.Item($r, 4).Text.Trim()
        $c5 = $Sheet.Cells.Item($r, 5).Text.Trim()

        # Header row: category name present, value column empty
        $lCat = if ($c1 -and -not $c2) { Get-TeamCategoryId $c1 } else { $null }
        $rCat = if ($c4 -and -not $c5) { Get-TeamCategoryId $c4 } else { $null }

        if ($lCat -or $rCat) {
            if ($lCat) { $currentLeft  = $lCat; $data[$lCat] = [System.Collections.Generic.List[PSCustomObject]]@() }
            if ($rCat) { $currentRight = $rCat; $data[$rCat] = [System.Collections.Generic.List[PSCustomObject]]@() }
            continue
        }

        # Skip blank rows
        if (-not $c1 -and -not $c4) { continue }

        # Left data row
        if ($currentLeft -and $c1 -and $c2 -match '^\d+$') {
            $clubId = Get-ClubId $c1
            if ($clubId) {
                $data[$currentLeft].Add([PSCustomObject]@{ Club = $clubId; Total = [int]$c2 })
            }
        }

        # Right data row
        if ($currentRight -and $c4 -and $c5 -match '^\d+$') {
            $clubId = Get-ClubId $c4
            if ($clubId) {
                $data[$currentRight].Add([PSCustomObject]@{ Club = $clubId; Total = [int]$c5 })
            }
        }
    }

    return $data
}

function Parse-SeasonTotals {
    param($Sheet, [string]$RaceId)

    # Map race ID -> column header name used in Season Totals
    $raceHeaderMap = @{
        "blackpool" = "Blackpool"
        "lytham"    = "Lytham"
        "preston"   = "Preston"
        "thornton"  = "Thornton"
        "wesham"    = "Wesham"
        "chorley"   = "Chorley"
        "red-rose"  = "Red Rose"
    }

    $headerName = $raceHeaderMap[$RaceId.ToLower()]
    if (-not $headerName) {
        Write-Warning "Race '$RaceId' has no column mapping for Season Totals; skipping."
        return $null
    }

    # Find the race column — scan up to row 15 for the header row
    $totalCols = $Sheet.UsedRange.Columns.Count
    $totalRows = $Sheet.UsedRange.Rows.Count
    $raceCol   = -1
    $headerRow = -1
    for ($hr = 1; $hr -le [Math]::Min(15, $totalRows); $hr++) {
        for ($c = 1; $c -le $totalCols; $c++) {
            if ($Sheet.Cells.Item($hr, $c).Text.Trim() -ieq $headerName) {
                $raceCol   = $c
                $headerRow = $hr
                break
            }
        }
        if ($raceCol -ne -1) { break }
    }
    if ($raceCol -eq -1) {
        Write-Warning "Column '$headerName' not found in Season Totals header row; skipping."
        return $null
    }
    Write-Host "  Season Totals header row: $headerRow  (column $raceCol = '$headerName')" -ForegroundColor DarkGray

    $totals     = @{}   # category_id -> club_id -> points
    $currentCat = $null

    for ($r = $headerRow + 1; $r -le $totalRows; $r++) {
        $c1  = $Sheet.Cells.Item($r, 1).Text.Trim()
        $cRa = $Sheet.Cells.Item($r, $raceCol).Text.Trim()

        # Category header: known category name, race column empty
        if ($c1 -and -not $cRa) {
            $catId = Get-TeamCategoryId $c1
            if ($catId) {
                $currentCat = $catId
                $totals[$catId] = @{}
                continue
            }
        }

        if (-not $currentCat) { continue }

        # Data row: club name + points
        $clubId = Get-ClubId $c1
        if ($clubId -and $cRa -match '^\d+$') {
            $totals[$currentCat][$clubId] = [int]$cRa
        }
    }

    return $totals
}

# Parses the 2015-format "Teams" sheet, which combines what the newer format
# splits across "Team Scorers" and "Team Positions".
#
# Layout per category block:
#   [optional] category label row — category name in col 8 (absent for first block)
#   club header row               — club names in even columns (2,4,6,…)
#   scorer rows                   — [pos][name] pairs per club
#   totals row                    — sum-of-positions in odd cols, "Nth" in even cols
#
# Returns a hashtable with two keys:
#   Scorers   — catId → clubId → List[{Position, Name}]
#   Positions — catId → ordered List[{Club, Total}]  (sorted by race rank)
function Parse-Teams2015 {
    param($Sheet, [string[]]$CategoryOrder)

    $totalRows = $Sheet.UsedRange.Rows.Count
    $totalCols = $Sheet.UsedRange.Columns.Count

    $scorers   = @{}
    $positions = @{}

    $currentCatId = $null
    $pendingCatId = $null   # category label seen just before the next club-header row
    $catIdx       = 0
    $inData       = $false
    $clubCols     = [ordered]@{}   # displayName -> {PosCol, NameCol}

    for ($r = 1; $r -le $totalRows; $r++) {

        # ── Category label in col 1 or col 8 (non-first categories only) ────
        if (-not $inData) {
            $foundCatId = $null
            foreach ($labelCol in @(1, 8)) {
                $labelVal = $Sheet.Cells.Item($r, $labelCol).Text.Trim()
                if ($labelVal) {
                    $foundCatId = Get-TeamCategoryId $labelVal
                    if ($foundCatId) { break }
                }
            }
            if ($foundCatId) { $pendingCatId = $foundCatId; continue }
        }

        # ── Club header row — any row with 2+ club names ──────────────────────
        $found = [ordered]@{}
        for ($c = 1; $c -le $totalCols; $c++) {
            $h = $Sheet.Cells.Item($r, $c).Text.Trim()
            if ($h) {
                $cId = Get-ClubId $h
                if ($null -ne $cId -and $cId -ne 'Guest') {
                    $found[$h] = [PSCustomObject]@{ PosCol = $c - 1; NameCol = $c }
                }
            }
        }

        if ($found.Count -ge 2) {
            if ($pendingCatId) {
                $currentCatId = $pendingCatId; $pendingCatId = $null
            } elseif ($catIdx -lt $CategoryOrder.Count) {
                $currentCatId = $CategoryOrder[$catIdx++]
            }
            $clubCols = $found
            $inData   = $true

            if (-not $scorers.ContainsKey($currentCatId)) {
                $scorers[$currentCatId] = @{}
                foreach ($cn in $clubCols.Keys) {
                    $cId = Get-ClubId $cn
                    if ($null -ne $cId) { $scorers[$currentCatId][$cId] = [System.Collections.Generic.List[PSCustomObject]]@() }
                }
            }
            continue
        }

        # Some formats omit the club header row for non-first categories, and some also omit
        # the category label row (e.g. wesham 2010 VETS section has neither).
        # When we have a pending category or unprocessed categories remain, check whether this
        # row is scorer data and if so start the next category without a header/label row.
        $nextUnlabeled = $null
        if (-not $pendingCatId) {
            $nextUnlabeled = $CategoryOrder | Where-Object { -not $scorers.ContainsKey($_) } | Select-Object -First 1
        }
        if (($pendingCatId -or $nextUnlabeled) -and $clubCols.Count -ge 2 -and -not $inData) {
            $hasData = $false
            foreach ($cn in $clubCols.Keys) {
                if ($Sheet.Cells.Item($r, $clubCols[$cn].PosCol).Text.Trim() -match '^\d+$') {
                    $hasData = $true; break
                }
            }
            if ($hasData) {
                if ($pendingCatId) {
                    $currentCatId = $pendingCatId; $pendingCatId = $null
                } else {
                    $currentCatId = $nextUnlabeled
                }
                $inData = $true
                if (-not $scorers.ContainsKey($currentCatId)) {
                    $scorers[$currentCatId] = @{}
                    foreach ($cn in $clubCols.Keys) {
                        $cId = Get-ClubId $cn
                        if ($null -ne $cId) { $scorers[$currentCatId][$cId] = [System.Collections.Generic.List[PSCustomObject]]@() }
                    }
                }
                # Fall through to process this row as scorer data below
            }
        }

        if (-not $inData -or -not $currentCatId) { continue }

        # ── Totals row — even cols contain position strings like "1st","2nd" ──
        $isTotals = $false
        foreach ($cn in $clubCols.Keys) {
            $val = $Sheet.Cells.Item($r, $clubCols[$cn].NameCol).Text.Trim()
            if ($val -match '\b(\d+)(?:st|nd|rd|th)\b') { $isTotals = $true; break }
        }

        if ($isTotals) {
            $rankList = [System.Collections.Generic.List[PSCustomObject]]@()
            foreach ($cn in $clubCols.Keys) {
                $cols     = $clubCols[$cn]
                $totalStr = $Sheet.Cells.Item($r, $cols.PosCol).Text.Trim()
                $rankStr  = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()
                if ($totalStr -match '^\d+$' -and $rankStr -match '(\d+)(?:st|nd|rd|th)') {
                    $cId = Get-ClubId $cn
                    if ($cId -and $cId -ne 'Guest') {
                        $rankList.Add([PSCustomObject]@{ Club = $cId; Total = [int]$totalStr; Rank = [int]$Matches[1] })
                    }
                }
            }
            $positions[$currentCatId] = [System.Collections.Generic.List[PSCustomObject]]@(
                $rankList | Sort-Object Rank | ForEach-Object { [PSCustomObject]@{ Club = $_.Club; Total = $_.Total } }
            )
            $inData = $false; $currentCatId = $null
            continue
        }

        # ── Scorer data row ────────────────────────────────────────────────────
        foreach ($cn in $clubCols.Keys) {
            $cols       = $clubCols[$cn]
            $scorerPos  = $Sheet.Cells.Item($r, $cols.PosCol).Text.Trim()
            $scorerName = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()

            if ($scorerPos -notmatch '^\d+$' -or -not $scorerName) { continue }

            $cId = Get-ClubId $cn
            if ($cId -and $cId -ne 'Guest' -and $scorers[$currentCatId].ContainsKey($cId)) {
                $scorers[$currentCatId][$cId].Add([PSCustomObject]@{
                    Position = [int]$scorerPos
                    Name     = $scorerName
                })
            }
        }
    }

    Write-Host "  Teams2015: scorers for categories: $($scorers.Keys -join ', ')" -ForegroundColor DarkGray
    Write-Host "  Teams2015: positions for categories: $($positions.Keys -join ', ')" -ForegroundColor DarkGray
    return @{ Scorers = $scorers; Positions = $positions }
}

# Parses the 2015-format "Tables" sheet to extract the current race's team points
# per category per club — equivalent to Parse-SeasonTotals for the newer format.
#
# Layout: one section per category.  Each section has a header row with the
# category name in col 1 and race abbreviations across subsequent columns
# (e.g. BWF, LSA, PH, TC, WRR, CAC, RR), then club rows with the club name in
# col 1 and that race's points in the corresponding column.
#
# The race column is located by matching $RaceId against the abbreviation map.
function Parse-SeasonTotals2015 {
    param($Sheet, [string]$RaceId)

    $raceAbbrevMap = @{
        "blackpool" = @("BWF", "BPL")
        "lytham"    = @("LSA")
        "preston"   = @("PH")
        "thornton"  = @("TC")
        "wesham"    = @("WRR")
        "chorley"   = @("CAC", "CAT")
        "red-rose"  = @("RR")
    }

    $targetAbbrevs = $raceAbbrevMap[$RaceId.ToLower()]
    if (-not $targetAbbrevs) {
        Write-Warning "No abbreviation mapping for race '$RaceId' in 2015 Tables format; skipping season totals."
        return $null
    }

    $totalRows = $Sheet.UsedRange.Rows.Count
    $totalCols = $Sheet.UsedRange.Columns.Count

    # Phase 1 — locate the column for the current race
    $raceCol = -1
    for ($r = 1; $r -le $totalRows -and $raceCol -eq -1; $r++) {
        for ($c = 2; $c -le $totalCols; $c++) {
            if ($targetAbbrevs -contains $Sheet.Cells.Item($r, $c).Text.Trim()) {
                $raceCol = $c
                Write-Host "  Tables2015: race '$RaceId' → column $raceCol (row $r)" -ForegroundColor DarkGray
                break
            }
        }
    }

    if ($raceCol -eq -1) {
        Write-Warning "Race abbreviation '$($targetAbbrevs -join '/')' not found in Tables sheet; skipping season totals."
        return $null
    }

    # Phase 2 — collect per-category per-club points
    $totals     = @{}
    $currentCat = $null

    for ($r = 1; $r -le $totalRows; $r++) {
        $c1  = $Sheet.Cells.Item($r, 1).Text.Trim()
        $pts = $Sheet.Cells.Item($r, $raceCol).Text.Trim()

        if (-not $c1) { continue }

        $catId = Get-TeamCategoryId $c1
        if ($catId) {
            $currentCat = $catId
            $totals[$catId] = @{}
            continue
        }

        if ($currentCat) {
            $clubId = Get-ClubId $c1
            if ($clubId -and $clubId -ne 'Guest' -and $pts -match '^\d+$') {
                $totals[$currentCat][$clubId] = [int]$pts
            }
        }
    }

    return $totals
}

# Parses the 2010-format "Teams" (or "teams") sheet.
#
# Two layout variants exist within the same year:
#   Compact  (6 cols): row 1 = club names; data cells contain "pos Name" in one cell
#   Paired  (12 cols): club names in even cols (2,4,…); odd cols = pos, even cols = name
#
# Both variants interleave all team categories in one sheet, separated by single-cell
# category-label rows ("Ladies", "VETS", "VET-50", "VET-60").  The Open block is first
# and has no explicit label.  Each block ends with a totals/rank row (cells that contain
# ordinal strings like "1st", "2nd") which is skipped; rankings are derived by summing
# scorer positions (lower total = better finish, as in cross-country scoring).
#
# Returns: @{ Scorers = catId→clubId→List[{Position,Name}]; Positions = catId→List[{Club,Total}] }
function Parse-Teams2010 {
    param($Sheet, [string[]]$CategoryOrder)

    $totalRows = $Sheet.UsedRange.Rows.Count
    $totalCols = $Sheet.UsedRange.Columns.Count
    $isCompact = ($totalCols -le 6)

    # Locate club-header row (first row with 2+ recognised club names)
    $headerRow = -1
    $clubCols  = [ordered]@{}   # displayName → {PosCol, NameCol}

    for ($hr = 1; $hr -le [Math]::Min(5, $totalRows); $hr++) {
        $found = [ordered]@{}
        for ($c = 1; $c -le $totalCols; $c++) {
            $h   = $Sheet.Cells.Item($hr, $c).Text.Trim()
            $cId = if ($h) { Get-ClubId $h } else { $null }
            if ($null -ne $cId -and $cId -ne 'Guest') {
                $posCol = if ($isCompact) { 0 } else { $c - 1 }
                $found[$h] = [PSCustomObject]@{ PosCol = $posCol; NameCol = $c }
            }
        }
        if ($found.Count -ge 2) { $headerRow = $hr; $clubCols = $found; break }
    }
    if ($clubCols.Count -eq 0) { throw "Could not find club header row in Teams2010 sheet" }

    Write-Host "  Teams2010: header=$headerRow clubs=$($clubCols.Count) format=$(if ($isCompact) {'compact'} else {'paired'})" -ForegroundColor DarkGray

    # Initialise first (implicit Open) category
    $currentCat = if ($CategoryOrder.Count -gt 0) { $CategoryOrder[0] } else { "open" }
    $scorers    = @{}
    $positions  = @{}

    $scorers[$currentCat] = @{}
    foreach ($cn in $clubCols.Keys) {
        $cId = Get-ClubId $cn
        if ($cId -and $cId -ne 'Guest') { $scorers[$currentCat][$cId] = [System.Collections.Generic.List[PSCustomObject]]@() }
    }

    for ($r = $headerRow + 1; $r -le $totalRows; $r++) {

        # Collect non-empty cells (plain hashtable — integer keys work as keys, not indices)
        $cells = @{}
        for ($c = 1; $c -le $totalCols; $c++) {
            $v = $Sheet.Cells.Item($r, $c).Text.Trim()
            if ($v) { $cells[$c] = $v }
        }
        if ($cells.Count -eq 0) { continue }

        # Category-label row: exactly one non-empty cell whose value is a known category
        if ($cells.Count -eq 1) {
            $singleVal = $cells.Values | Select-Object -First 1
            $newCatId  = Get-TeamCategoryId $singleVal
            if ($newCatId) {
                $currentCat = $newCatId
                $scorers[$currentCat] = @{}
                foreach ($cn in $clubCols.Keys) {
                    $cId = Get-ClubId $cn
                    if ($cId -and $cId -ne 'Guest') { $scorers[$currentCat][$cId] = [System.Collections.Generic.List[PSCustomObject]]@() }
                }
                continue
            }
        }

        # Totals/rank row — read rank and actual total directly from the spreadsheet
        $isTotals = $false
        foreach ($v in $cells.Values) {
            if ($v -match '\b\d+(?:st|nd|rd|th)\b') { $isTotals = $true; break }
        }
        if ($isTotals) {
            $rankList = [System.Collections.Generic.List[PSCustomObject]]@()
            foreach ($cn in $clubCols.Keys) {
                $cols = $clubCols[$cn]
                $cId  = Get-ClubId $cn
                if (-not $cId -or $cId -eq 'Guest') { continue }

                $rank  = $null
                $total = $null

                if ($isCompact) {
                    # Compact: single cell contains "2nd 167" or just "2nd"
                    $cv = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()
                    if ($cv -match '^(\d+)(?:st|nd|rd|th)\s+(\d+)') {
                        $rank = [int]$Matches[1]; $total = [int]$Matches[2]
                    } elseif ($cv -match '^(\d+)(?:st|nd|rd|th)') {
                        $rank = [int]$Matches[1]
                    }
                } else {
                    # Paired: name col may have "3rd" or "1039 6th"; pos col may have total
                    $nv = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()
                    $pv = if ($cols.PosCol -gt 0) { $Sheet.Cells.Item($r, $cols.PosCol).Text.Trim() } else { "" }
                    if ($nv -match '^(\d+)\s+(\d+)(?:st|nd|rd|th)') {
                        $total = [int]$Matches[1]; $rank = [int]$Matches[2]
                    } elseif ($nv -match '^(\d+)(?:st|nd|rd|th)') {
                        $rank = [int]$Matches[1]   # save rank NOW before $pv match overwrites $Matches
                        if ($pv -match '^\d+$') { $total = [int]$pv }
                    }
                }

                if ($null -ne $rank) {
                    $rankList.Add([PSCustomObject]@{ Club = $cId; Rank = $rank; Total = $total })
                }
            }

            if ($rankList.Count -gt 0) {
                $positions[$currentCat] = [System.Collections.Generic.List[PSCustomObject]]@(
                    $rankList | Sort-Object Rank | ForEach-Object { [PSCustomObject]@{ Club = $_.Club; Total = $_.Total } }
                )
            }
            continue
        }

        # Scorer data row
        foreach ($cn in $clubCols.Keys) {
            $cols       = $clubCols[$cn]
            $scorerPos  = $null
            $scorerName = ""

            if ($isCompact) {
                $cv = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()
                if ($cv -match '^(\d+)\s*(.+)$') { $scorerPos = [int]$Matches[1]; $scorerName = $Matches[2].Trim() }
            } else {
                $pv = if ($cols.PosCol -gt 0) { $Sheet.Cells.Item($r, $cols.PosCol).Text.Trim() } else { "" }
                $nv = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()
                if ($pv -match '^\d+$' -and $nv) { $scorerPos = [int]$pv; $scorerName = $nv }
            }

            if ($null -ne $scorerPos -and $scorerName) {
                $cId = Get-ClubId $cn
                if ($cId -and $cId -ne 'Guest' -and $scorers[$currentCat].ContainsKey($cId)) {
                    $scorers[$currentCat][$cId].Add([PSCustomObject]@{ Position = $scorerPos; Name = $scorerName })
                }
            }
        }
    }

    Write-Host "  Teams2010 categories parsed: $($positions.Keys -join ', ')" -ForegroundColor DarkGray
    return @{ Scorers = $scorers; Positions = $positions }
}

# ─── 2009 format helpers ──────────────────────────────────────────────────────

# Converts a 2009-style category string to the site's SEN/V40/V45/... format.
# Handles: M, MJ, F, FJ → SEN; V40 → V40; FV40, F45 → V40, V45.
function Normalize-Category2009 {
    param([string]$Cat)
    $c = $Cat.Trim()
    switch -Regex ($c) {
        '^(?i)(M|MJ|FJ|F)$' { return "SEN" }
        '^(?i)FV?(\d+)$'    { return "V$($Matches[1])" }
        '^(?i)V(\d+)$'      { return "V$($Matches[1])" }
        default             { return $c }
    }
}

# Derives sex from a 2009 category string; F-prefix categories are female.
function Get-Sex2009 {
    param([string]$Cat)
    if ($Cat.Trim() -imatch '^F') { return "F" }
    return "M"
}

# Splits a full name on the last space: "John Smith" → {First="John", Last="Smith"}.
function Split-Name2009 {
    param([string]$FullName)
    $n   = $FullName.Trim()
    $idx = $n.LastIndexOf(' ')
    if ($idx -lt 0) { return @{ First = $n; Last = "" } }
    return @{ First = $n.Substring(0, $idx).Trim(); Last = $n.Substring($idx + 1).Trim() }
}

# Parses the 2009-format "Main" sheet.
#
# Two layouts exist:
#   Form-control (race 1):  header in row 1 with [#] checkbox controls in odd cols;
#     data in even cols: 2=Pos, 4=IC, 14=Name, 16=Cat, 18=Club, 20=Time
#   Multi-column (races 2-6): four data blocks across two row bands:
#     rows 2-65:  cols 1-10 (pos 1-64) and cols 12-21 (pos 65-128)
#     rows 68+:   cols 1-10 (pos 129-178) and cols 12-21 (pos 179+)
#     (row 66 blank, row 67 repeat header)
#     Col layout per block: Pos IC V V50 V60 L Name Cat Club Time
#
# Returns results in position order; names are split first/last on the final space.
function Parse-Main2009 {
    param($Sheet)

    $totalRows = $Sheet.UsedRange.Rows.Count
    $results   = [System.Collections.Generic.List[PSCustomObject]]@()

    $isFormControl = ($Sheet.Cells.Item(1, 2).Text.Trim() -ieq "Pos")

    if ($isFormControl) {
        for ($r = 2; $r -le $totalRows; $r++) {
            $pos = $Sheet.Cells.Item($r, 2).Text.Trim()
            if ($pos -notmatch '^\d+$') { continue }

            $icPos   = $Sheet.Cells.Item($r,  4).Text.Trim()
            $name    = $Sheet.Cells.Item($r, 14).Text.Trim()
            $cat     = $Sheet.Cells.Item($r, 16).Text.Trim()
            $clubRaw = $Sheet.Cells.Item($r, 18).Text.Trim()
            $time    = $Sheet.Cells.Item($r, 20).Text.Trim()

            $np    = Split-Name2009 $name
            $clubId = Get-ClubId $clubRaw
            if ($null -eq $clubId) { Write-Warning "Row ${r}: unknown club '$clubRaw'"; $clubId = "Guest" }

            $results.Add([PSCustomObject]@{
                ExcelRow = $r
                Position = [int]$pos
                IcPos    = if ($icPos -match '^\d+$') { [int]$icPos } else { $null }
                RaceNum  = $null
                First    = $np.First
                Last     = $np.Last
                Club     = $clubId
                Category = Normalize-Category2009 $cat
                Sex      = Get-Sex2009 $cat
                Time     = $time
                CategoryPositions = @{}
            })
        }
    } else {
        # Multi-column: left block (cols 1-10) then right block (cols 12-21)
        # Cols 3-6 / 14-17 carry per-runner category-rank positions: V=vets, V50=v50, V60=v60, L=ladies
        $blocks = @(
            [PSCustomObject]@{ PosCol=1;  IcCol=2;  VetsCol=3;  V50Col=4;  V60Col=5;  LadiesCol=6;  NameCol=7;  CatCol=8;  ClubCol=9;  TimeCol=10 },
            [PSCustomObject]@{ PosCol=12; IcCol=13; VetsCol=14; V50Col=15; V60Col=16; LadiesCol=17; NameCol=18; CatCol=19; ClubCol=20; TimeCol=21 }
        )
        foreach ($blk in $blocks) {
            for ($r = 2; $r -le $totalRows; $r++) {
                $pos = $Sheet.Cells.Item($r, $blk.PosCol).Text.Trim()
                if ($pos -notmatch '^\d+$') { continue }

                $icPos    = $Sheet.Cells.Item($r, $blk.IcCol).Text.Trim()
                $vetsPos  = $Sheet.Cells.Item($r, $blk.VetsCol).Text.Trim()
                $v50Pos   = $Sheet.Cells.Item($r, $blk.V50Col).Text.Trim()
                $v60Pos   = $Sheet.Cells.Item($r, $blk.V60Col).Text.Trim()
                $ladiesPos = $Sheet.Cells.Item($r, $blk.LadiesCol).Text.Trim()
                $name    = $Sheet.Cells.Item($r, $blk.NameCol).Text.Trim()
                $cat     = $Sheet.Cells.Item($r, $blk.CatCol).Text.Trim()
                $clubRaw = $Sheet.Cells.Item($r, $blk.ClubCol).Text.Trim()
                $time    = $Sheet.Cells.Item($r, $blk.TimeCol).Text.Trim()

                if (-not $name -and -not $time) { continue }

                $np     = Split-Name2009 $name
                $clubId = Get-ClubId $clubRaw
                if ($null -eq $clubId) { Write-Warning "Row ${r} col $($blk.PosCol): unknown club '$clubRaw'"; $clubId = "Guest" }

                $catPositions = @{
                    vets   = if ($vetsPos   -match '^\d+$') { [int]$vetsPos }   else { $null }
                    v50    = if ($v50Pos    -match '^\d+$') { [int]$v50Pos }    else { $null }
                    v60    = if ($v60Pos    -match '^\d+$') { [int]$v60Pos }    else { $null }
                    ladies = if ($ladiesPos -match '^\d+$') { [int]$ladiesPos } else { $null }
                }

                $results.Add([PSCustomObject]@{
                    ExcelRow = $r
                    Position = [int]$pos
                    IcPos    = if ($icPos -match '^\d+$') { [int]$icPos } else { $null }
                    RaceNum  = $null
                    First    = $np.First
                    Last     = $np.Last
                    Club     = $clubId
                    Category = Normalize-Category2009 $cat
                    Sex      = Get-Sex2009 $cat
                    Time     = $time
                    CategoryPositions = $catPositions
                })
            }
        }
        $results = [System.Collections.Generic.List[PSCustomObject]]@($results | Sort-Object Position)
    }

    Write-Host "  Layout: $(if ($isFormControl) { 'form-control' } else { 'multi-column' })  |  $($results.Count) runners" -ForegroundColor DarkGray
    return $results
}

# Parses a 2009 team-scorer sheet (Overall, Vets, or Women).
#
# Layout: 6 clubs × 4 columns (pos, name, cat, blank), club names at cols 2,6,10,14,18,22.
# Scorer rows: position in PosCol, name in NameCol.
# Totals/rank row: ordinal string ("1st") in NameCol for club 1.
# Category label rows (Vets sheet): category name in col 1 on the same row as the club header.
#
# The Vets sheet contains three interleaved sections (Vets, V50, V60);
# $DefaultCatId applies to the first section when no label precedes it.
#
# Returns @{ Scorers = catId→clubId→List[{Position,Name}]; Positions = catId→List[{Club,Total}] }
function Parse-Teams2009Sheet {
    param($Sheet, [string]$DefaultCatId)

    $totalRows    = $Sheet.UsedRange.Rows.Count
    # Club columns repeat in 4-col blocks (pos, name, cat, blank) starting at col 2.
    # Sized dynamically from the sheet's used range rather than a fixed 6-club count,
    # since some years (e.g. 2006) field 7 interclub clubs.
    $totalCols    = $Sheet.UsedRange.Columns.Count
    $maxClubCol   = [Math]::Max(22, $totalCols)
    $slotCount    = [int][Math]::Floor(($maxClubCol - 2) / 4) + 1
    $nameColsList = 1..$slotCount | ForEach-Object { 2 + 4 * ($_ - 1) }

    $scorers    = @{}
    $positions  = @{}
    $currentCat = $DefaultCatId
    $clubCols   = @()

    for ($r = 1; $r -le $totalRows; $r++) {
        $c1 = $Sheet.Cells.Item($r, 1).Text.Trim()
        $c2 = $Sheet.Cells.Item($r, 2).Text.Trim()

        # Club-header row: col 2 is a recognised non-Guest club
        $c2Id = if ($c2) { Get-ClubId $c2 } else { $null }
        if ($null -ne $c2Id -and $c2Id -ne 'Guest') {
            if ($c1) {
                $lc = Get-TeamCategoryId $c1
                if ($lc) { $currentCat = $lc }
            }
            $clubCols = @()
            foreach ($nc in $nameColsList) {
                $cn  = $Sheet.Cells.Item($r, $nc).Text.Trim()
                $cId = if ($cn) { Get-ClubId $cn } else { $null }
                if ($null -ne $cId -and $cId -ne 'Guest') {
                    $clubCols += [PSCustomObject]@{ PosCol = $nc - 1; NameCol = $nc; ClubId = $cId }
                }
            }
            if (-not $scorers.ContainsKey($currentCat)) { $scorers[$currentCat] = @{} }
            foreach ($cc in $clubCols) {
                if (-not $scorers[$currentCat].ContainsKey($cc.ClubId)) {
                    $scorers[$currentCat][$cc.ClubId] = [System.Collections.Generic.List[PSCustomObject]]@()
                }
            }
            Write-Host "  Teams2009Sheet: cat=$currentCat clubs=$($clubCols.Count)" -ForegroundColor DarkGray
            continue
        }

        if ($clubCols.Count -eq 0) { continue }

        # Totals/rank row: col 2 contains an ordinal string
        if ($c2 -match '\d+(?:st|nd|rd|th)') {
            $rankList = [System.Collections.Generic.List[PSCustomObject]]@()
            foreach ($cc in $clubCols) {
                $totalStr = $Sheet.Cells.Item($r, $cc.PosCol).Text.Trim()
                $rankStr  = $Sheet.Cells.Item($r, $cc.NameCol).Text.Trim()
                if ($rankStr -match '(\d+)(?:st|nd|rd|th)') {
                    $rankList.Add([PSCustomObject]@{
                        ClubId = $cc.ClubId
                        Rank   = [int]$Matches[1]
                        Total  = if ($totalStr -match '^\d+$') { [int]$totalStr } else { $null }
                    })
                }
            }
            $positions[$currentCat] = [System.Collections.Generic.List[PSCustomObject]]@(
                $rankList | Sort-Object Rank | ForEach-Object { [PSCustomObject]@{ Club = $_.ClubId; Total = $_.Total } }
            )
            $clubCols = @()
            continue
        }

        # Skip rows with no scorer data
        $hasData = $false
        foreach ($cc in $clubCols) {
            if ($Sheet.Cells.Item($r, $cc.PosCol).Text.Trim() -match '^\d+$') { $hasData = $true; break }
        }
        if (-not $hasData) { continue }

        # Scorer row
        foreach ($cc in $clubCols) {
            $scorerPos  = $Sheet.Cells.Item($r, $cc.PosCol).Text.Trim()
            $scorerName = $Sheet.Cells.Item($r, $cc.NameCol).Text.Trim()
            if ($scorerPos -match '^\d+$' -and $scorerName) {
                $scorers[$currentCat][$cc.ClubId].Add([PSCustomObject]@{
                    Position = [int]$scorerPos
                    Name     = $scorerName
                })
            }
        }
    }

    return @{ Scorers = $scorers; Positions = $positions }
}

# Parses the 2009-format "Tables" sheet to extract per-race team points.
#
# Layout: category label in col 1 alone (OPEN, WOMEN, VETS, VET50, VET60),
# followed by a header row (col 1 starts with "Club"; race abbreviations in cols 2+),
# then club-data rows (club name in col 1, points in race column).
#
# Returns catId → clubId → points (same shape as Parse-SeasonTotals).
function Parse-Tables2009 {
    param($Sheet, [string]$RaceId)

    $raceAbbrevMap = @{
        "blackpool" = @("BWF", "BPL")
        "lytham"    = @("LSA")
        "preston"   = @("PH")
        "wesham"    = @("WRR")
        "chorley"   = @("CAC", "CAT")
        "red-rose"  = @("RR")
    }

    $totalRows     = $Sheet.UsedRange.Rows.Count
    $totalCols     = $Sheet.UsedRange.Columns.Count
    $targetAbbrevs = $raceAbbrevMap[$RaceId.ToLower()]
    if (-not $targetAbbrevs) {
        Write-Warning "No race abbreviation mapping for '$RaceId' in 2009 Tables; skipping."
        return $null
    }

    $totals     = @{}
    $currentCat = $null
    $raceCol    = -1

    for ($r = 1; $r -le $totalRows; $r++) {
        $c1 = $Sheet.Cells.Item($r, 1).Text.Trim()
        if (-not $c1) { continue }

        $catId = Get-TeamCategoryId $c1
        if ($catId) {
            $currentCat = $catId
            $totals[$catId] = @{}
            $raceCol = -1
            continue
        }

        if ($c1 -imatch '^Club') {
            $raceCol = -1
            for ($c = 2; $c -le $totalCols; $c++) {
                if ($targetAbbrevs -contains $Sheet.Cells.Item($r, $c).Text.Trim()) {
                    $raceCol = $c
                    Write-Host "  Tables2009: '$RaceId' → col $raceCol (row $r)" -ForegroundColor DarkGray
                    break
                }
            }
            continue
        }

        if ($currentCat -and $raceCol -gt 0) {
            $clubId = Get-ClubId $c1
            if ($clubId -and $clubId -ne 'Guest') {
                $pts = $Sheet.Cells.Item($r, $raceCol).Text.Trim()
                if ($pts -match '^\d+$') {
                    $totals[$currentCat][$clubId] = [int]$pts
                }
            }
        }
    }

    return $totals
}

# ─── Output builders ──────────────────────────────────────────────────────────

function Build-TeamResultsJson {
    param($TeamPositions, $TeamScorers, [string[]]$CategoryOrder, [string[]]$AllClubs)

    $numClubs = $AllClubs.Count   # total clubs in the series, incl. non-scoring ones

    # Mapping from Team Scorers display name -> club ID
    $scorerClubMap = @{
        "Blackpool" = "blackpool"
        "Chorley"   = "chorley-ac"
        "Lytham"    = "lytham"
        "Preston"   = "preston"
        "Red Rose"  = "red-rose"
        "Thornton"  = "thornton"
        "Wesham"    = "wesham"
    }

    $categories = [System.Collections.Generic.List[object]]@()

    foreach ($catId in $CategoryOrder) {
        if (-not $TeamPositions.ContainsKey($catId)) { continue }

        $orderedClubs = $TeamPositions[$catId]
        $clubs = [System.Collections.Generic.List[object]]@()

        for ($i = 0; $i -lt $orderedClubs.Count; $i++) {
            $entry    = $orderedClubs[$i]
            $position = $i + 1
            $points   = $numClubs - $position + 1

            # Collect scorers — try club ID first (2015 format), then display-name map (current format)
            $scorers = [System.Collections.Generic.List[object]]@()
            if ($TeamScorers.ContainsKey($catId)) {
                $clubScorers = $null
                if ($TeamScorers[$catId].ContainsKey($entry.Club)) {
                    $clubScorers = $TeamScorers[$catId][$entry.Club]
                } else {
                    foreach ($displayName in $scorerClubMap.Keys) {
                        if ($scorerClubMap[$displayName] -eq $entry.Club -and $TeamScorers[$catId].ContainsKey($displayName)) {
                            $clubScorers = $TeamScorers[$catId][$displayName]
                            break
                        }
                    }
                }
                if ($clubScorers) {
                    foreach ($s in $clubScorers) {
                        $scorers.Add([ordered]@{ position = $s.Position; name = $s.Name })
                    }
                }
            }

            $clubs.Add([ordered]@{
                position = $position
                points   = $points
                club     = $entry.Club
                total    = $entry.Total
                scorers  = $scorers.ToArray()
            })
        }

        # Any club with no totals-row entry (e.g. an incomplete team the source
        # spreadsheet excluded from ranking) is appended at the back of the field
        # rather than dropped from the category entirely — every club fields a
        # slot every race. Points still follow the numClubs-position+1 scale,
        # matching how genuinely non-scoring clubs are scored elsewhere.
        $rankedClubIds = @($orderedClubs | ForEach-Object { $_.Club })
        $missingClubs  = @($AllClubs | Where-Object { $_ -notin $rankedClubIds })
        $nextPosition  = $orderedClubs.Count + 1
        foreach ($missingClub in $missingClubs) {
            $clubs.Add([ordered]@{
                position = $nextPosition
                points   = $numClubs - $nextPosition + 1
                club     = $missingClub
                total    = $null
                scorers  = @()
            })
            $nextPosition++
        }

        $categories.Add([ordered]@{
            id    = $catId
            clubs = $clubs.ToArray()
        })
    }

    return [ordered]@{ categories = $categories.ToArray() }
}

function Update-TeamStandings {
    param(
        [string]$StandingsPath,
        [string]$RaceId,
        $PointsSource,         # hashtable: cat_id -> club_id -> points  (from Season Totals or Team Positions)
        [string[]]$AllClubs,
        [string[]]$AllCategories,
        [bool]$IsProvisional
    )

    # Load existing standings or start fresh
    if (Test-Path $StandingsPath) {
        $existing = Get-Content $StandingsPath -Raw | ConvertFrom-Json
        $races = [System.Collections.Generic.List[string]]@($existing.races)
    } else {
        $existing = $null
        $races    = [System.Collections.Generic.List[string]]@()
    }

    # Add race if not already present
    $raceIdx = $races.IndexOf($RaceId)
    if ($raceIdx -eq -1) {
        $races.Add($RaceId)
        $raceIdx = $races.Count - 1
    }

    $newCategories = [System.Collections.Generic.List[object]]@()

    foreach ($catId in $AllCategories) {
        # Find existing category entry
        $existingCat = if ($existing) {
            $existing.categories | Where-Object { $_.id -eq $catId } | Select-Object -First 1
        } else { $null }

        $clubs = [System.Collections.Generic.List[object]]@()

        foreach ($clubId in $AllClubs) {
            # Find existing club entry
            $existingClub = if ($existingCat) {
                $existingCat.clubs | Where-Object { $_.club -eq $clubId } | Select-Object -First 1
            } else { $null }

            # Build points array, extending to cover this race index
            $pointsArr = [System.Collections.Generic.List[object]]@()
            if ($existingClub -and $existingClub.points) {
                foreach ($p in $existingClub.points) { $pointsArr.Add($p) }
            }
            while ($pointsArr.Count -le $raceIdx) { $pointsArr.Add($null) }

            # Set this race's points
            $pts = $null
            if ($PointsSource.ContainsKey($catId) -and $PointsSource[$catId].ContainsKey($clubId)) {
                $pts = $PointsSource[$catId][$clubId]
            }
            $pointsArr[$raceIdx] = $pts

            # Recalculate total
            $total = 0
            foreach ($p in $pointsArr) { if ($null -ne $p) { $total += $p } }

            $clubs.Add([ordered]@{
                club       = $clubId
                points     = $pointsArr.ToArray()
                total      = $total
                tiebreaker = $null
            })
        }

        # Sort by total descending, assign positions
        $sorted = $clubs | Sort-Object { -$_.total }
        for ($i = 0; $i -lt $sorted.Count; $i++) {
            # Share position when tied
            $pos = $i + 1
            if ($i -gt 0 -and $sorted[$i].total -eq $sorted[$i - 1].total) {
                $pos = $sorted[$i - 1].position
            }
            $sorted[$i] = [ordered]@{
                position   = $pos
                club       = $sorted[$i].club
                points     = $sorted[$i].points
                total      = $sorted[$i].total
                tiebreaker = $null
            }
        }

        $newCategories.Add([ordered]@{
            id    = $catId
            clubs = @($sorted)
        })
    }

    return [ordered]@{
        provisional = $IsProvisional
        races       = $races.ToArray()
        categories  = $newCategories.ToArray()
    }
}

# ─── Main ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "InterClub Results Parser" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Collect missing parameters interactively
if (-not $ExcelFile) {
    $ExcelFile = Prompt-Value "Excel file path"
}
$ExcelFile = [System.IO.Path]::GetFullPath($ExcelFile)
if (-not (Test-Path $ExcelFile)) { throw "Excel file not found: $ExcelFile" }

if (-not $ProjectRoot) {
    $defaultRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $defaultRoot) { $defaultRoot = "" }
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path $ProjectRoot)) { throw "Project root not found: $ProjectRoot" }

if (-not $Year) {
    $Year = Prompt-Value "Series year (e.g. 2026)" "2026"
}
$script:chorleyClubId = if ([int]$Year -lt 2012) { "chorley-ac" } else { "chorley" }

if (-not $RaceId) {
    $RaceId = Prompt-Value "Race ID (e.g. blackpool, red-rose)"
}
$RaceId = $RaceId.ToLower()

if (-not $PSBoundParameters.ContainsKey('Provisional')) {
    $provInput  = Read-Host "Mark as provisional? (y/N)"
    $Provisional = $provInput -match '^[yY]'
}

# Derived paths
$dataDir       = Join-Path $ProjectRoot "src\data\$Year\$Series"
$resultsDir    = Join-Path $dataDir "results"
$suffix        = if ($Provisional) { "-provisional" } else { "" }
$csvFile       = Join-Path $resultsDir "$RaceId$suffix.csv"
$teamsFile     = Join-Path $resultsDir "$RaceId-teams$suffix.json"
$standingsFile = Join-Path $dataDir "team-standings.json"
$configFile    = Join-Path $dataDir "config.json"
$clubsFile     = Join-Path $ProjectRoot "src\data\$Year\clubs.json"
$xlsxExt       = [System.IO.Path]::GetExtension($ExcelFile)
$xlsxDest      = Join-Path $resultsDir "$RaceId$xlsxExt"

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  Excel:       $ExcelFile"
Write-Host "  Year:        $Year  |  Series: $Series  |  Race: $RaceId"
Write-Host "  Provisional: $Provisional"
Write-Host "  CSV out:     $csvFile"
Write-Host "  Teams out:   $teamsFile"
Write-Host "  Standings:   $standingsFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# Warn if output files already exist
foreach ($outFile in @($csvFile, $teamsFile)) {
    if (Test-Path $outFile) {
        Write-Warning "File already exists and will be overwritten: $outFile"
    }
}

# Load config
$config       = Get-Content $configFile -Raw | ConvertFrom-Json
$categoryIds  = @($config.teamCategories | ForEach-Object { $_.id })
$clubs        = Get-Content $clubsFile -Raw | ConvertFrom-Json
$clubIds      = @($clubs | ForEach-Object { $_.id })

# Build dynamic category map from config so Excel display names resolve to correct config IDs
$script:categoryMap = Build-CategoryMap $config.teamCategories
Write-Host "Category map: $(($script:categoryMap.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ', ')" -ForegroundColor DarkGray

# Open Excel via COM
Write-Host "Opening Excel..." -ForegroundColor DarkGray
$excel = New-Object -ComObject Excel.Application
$excel.Visible       = $false
$excel.DisplayAlerts = $false
$wb = $excel.Workbooks.Open($ExcelFile)

try {

    # ── Detect format ─────────────────────────────────────────────────────
    # 2010: Individual + Teams (no Tables sheet)
    # 2015: Individual + Teams + Tables
    # Current: Positions + Team Scorers + Team Positions + Season Totals
    $sheetNames      = @($wb.Sheets | ForEach-Object { $_.Name })
    $hasMain         = ($sheetNames | Where-Object { $_ -ieq "Main"       }).Count -gt 0
    $hasOverall      = ($sheetNames | Where-Object { $_ -ieq "Overall"    }).Count -gt 0
    $hasIndividual   = ($sheetNames | Where-Object { $_ -ieq "Individual" }).Count -gt 0
    $hasTables       = ($sheetNames | Where-Object { $_ -ieq "Tables"     }).Count -gt 0
    $hasTeams        = ($sheetNames | Where-Object { $_ -imatch '^teams?$' }).Count -gt 0
    $is2009Format    = $hasMain -and $hasOverall
    $isLegacyFormat  = $hasIndividual -and $hasTables
    $is2010Format    = $hasIndividual -and $hasTeams -and -not $hasTables
    if ($is2009Format) {
        Write-Host "Detected 2009 format (Main / Overall / Vets / Women / Tables)" -ForegroundColor Yellow
    } elseif ($is2010Format) {
        Write-Host "Detected 2010 format (Individual / Teams, no Tables)" -ForegroundColor Yellow
    } elseif ($isLegacyFormat) {
        Write-Host "Detected legacy 2015 format (Individual / Teams / Tables)" -ForegroundColor Yellow
    }

    # ── 1. Individual Results ──────────────────────────────────────────────
    if ($is2009Format) {
        Write-Host "Parsing Main sheet (2009)..." -ForegroundColor DarkGray
        $posSheet = $wb.Sheets.Item("Main")
        $results  = @(Parse-Main2009 $posSheet)
        # Main sheet carries per-runner category-rank columns (V/V50/V60/L) beyond IC/cat_open
        $script:catCols = @{ vets = 0; v50 = 0; v60 = 0; ladies = 0 }
    } else {
        $indvSheet    = $wb.Sheets | Where-Object { $_.Name -ieq "Individual" } | Select-Object -First 1
        $posSheetName = if ($indvSheet) { $indvSheet.Name } else { "Positions" }
        Write-Host "Parsing $posSheetName sheet..." -ForegroundColor DarkGray
        $posSheet = if ($indvSheet) { $indvSheet } else { $wb.Sheets.Item("Positions") }
        $results  = @(Parse-Positions $posSheet)
    }

    $icCount    = ($results | Where-Object { $null -ne $_.IcPos }).Count
    $guestCount = ($results | Where-Object { $null -eq $_.IcPos }).Count
    Write-Host "  $($results.Count) runners - $icCount IC, $guestCount guest"

    # Sort detected category IDs; cat_open is always first (from IC column)
    $sortedCatIds = @($script:catCols.Keys | Sort-Object)

    # Build CSV header: position, cat_open, [other cat columns], race_number, names, club, age_category, sex, time, series_runner_id
    $csvHeader = "position,cat_open"
    foreach ($catId in $sortedCatIds) {
        $csvHeader += ",cat_$catId"
    }
    $csvHeader += ",race_number,first_name,last_name,club,age_category,sex,time,series_runner_id"

    # Build CSV lines
    $csvLines = [System.Collections.Generic.List[string]]@($csvHeader)
    foreach ($r in $results) {
        $open = if ($null -ne $r.IcPos) { $r.IcPos } else { "" }
        $line = "$($r.Position),$open"

        # Add category position values in the same order as header
        foreach ($catId in $sortedCatIds) {
            $catVal = if ($r.CategoryPositions.ContainsKey($catId) -and $null -ne $r.CategoryPositions[$catId]) {
                $r.CategoryPositions[$catId]
            } else {
                ""
            }
            $line += ",$catVal"
        }

        $num = if ($null -ne $r.RaceNum) { $r.RaceNum } else { "" }
        $line += ",$num,$($r.First),$($r.Last),$($r.Club),$($r.Category),$($r.Sex),$($r.Time),"
        $csvLines.Add($line)
    }

    # ── 2. Validation - spot-check every 5 results ──────────────────────────
    Write-Host ""
    Write-Host "Validation" -ForegroundColor Yellow

    $errCount = 0
    if ($is2009Format) {
        foreach ($runner in ($results | Select-Object -First 5)) {
            Write-Host ("  OK  pos={0}  {1} {2}  {3}" -f $runner.Position, $runner.First, $runner.Last, $runner.Time) -ForegroundColor Green
        }
    } else {
        for ($i = 0; $i -lt $results.Count; $i += 5) {
            $runner   = $results[$i]
            $exRow    = $script:dataStartRow + $i
            $exPos    = $posSheet.Cells.Item($exRow, $script:colMap["Pos"]).Text.Trim()
            $exFirst  = $posSheet.Cells.Item($exRow, $script:colMap["First"]).Text.Trim()
            $exLast   = $posSheet.Cells.Item($exRow, $script:colMap["Last"]).Text.Trim()
            $exTime   = $posSheet.Cells.Item($exRow, $script:colMap["Time"]).Text.Trim()

            $rowLabel = "Result #$($i + 1) (Excel row $exRow)"
            $ok = $true

            if ([string]$runner.Position -ne $exPos) {
                Write-Warning "  $rowLabel position: expected '$exPos', got '$($runner.Position)'"
                $errCount++; $ok = $false
            }
            if ($runner.First -ne $exFirst) {
                Write-Warning "  $rowLabel first name: expected '$exFirst', got '$($runner.First)'"
                $errCount++; $ok = $false
            }
            if ($runner.Last.Trim() -ne $exLast.Trim()) {
                Write-Warning "  $rowLabel last name: expected '$exLast', got '$($runner.Last)'"
                $errCount++; $ok = $false
            }
            if ($runner.Time -ne $exTime) {
                Write-Warning "  $rowLabel time: expected '$exTime', got '$($runner.Time)'"
                $errCount++; $ok = $false
            }

            if ($ok) {
                $color = "Green"
                Write-Host ("  OK  #{0,-4} pos={1}  {2} {3}  {4}" -f ($i+1), $runner.Position, $runner.First, $runner.Last.Trim(), $runner.Time) -ForegroundColor $color
            }
        }
    }

    $countColor = if ($errCount -eq 0) { "Green" } else { "Red" }
    Write-Host ("  Total: {0} runners, {1} validation error(s)" -f $results.Count, $errCount) -ForegroundColor $countColor

    # ── 3-5. Team data — routed by format ─────────────────────────────────
    Write-Host ""
    if ($is2009Format) {

        # 2009: Overall = Open, Women = Women, Vets sheet = Vets + V50 + V60
        $teamScorers   = @{}
        $teamPositions = @{}

        foreach ($sheetSpec in @(
            [PSCustomObject]@{ SheetName = "Overall"; DefaultCat = "open"  },
            [PSCustomObject]@{ SheetName = "Women";   DefaultCat = "women" },
            [PSCustomObject]@{ SheetName = "Vets";    DefaultCat = "vets"  }
        )) {
            Write-Host "Parsing $($sheetSpec.SheetName) sheet (2009)..." -ForegroundColor DarkGray
            $sh   = $wb.Sheets.Item($sheetSpec.SheetName)
            $defaultCatId = Get-TeamCategoryId $sheetSpec.DefaultCat
            if (-not $defaultCatId) { $defaultCatId = $sheetSpec.DefaultCat }
            $data = Parse-Teams2009Sheet $sh $defaultCatId
            foreach ($k in $data.Scorers.Keys)   { $teamScorers[$k]   = $data.Scorers[$k]   }
            foreach ($k in $data.Positions.Keys) { $teamPositions[$k] = $data.Positions[$k] }
        }
        Write-Host "  Team categories: $($teamPositions.Keys -join ', ')"

        Write-Host "Parsing Tables sheet (2009)..." -ForegroundColor DarkGray
        $tablesSheet2009 = $wb.Sheets | Where-Object { $_.Name -ieq "Tables" -or $_.Name -ieq "master" } | Select-Object -First 1
        $seasonTotals = Parse-Tables2009 $tablesSheet2009 $RaceId

        if ($seasonTotals -and $seasonTotals.Count -gt 0) {
            Write-Host "  Season-totals categories: $($seasonTotals.Keys -join ', ')"
            $pointsSource = $seasonTotals
        } else {
            Write-Host "  Tables unavailable - deriving points from team positions" -ForegroundColor Yellow
            $pointsSource = @{}
            foreach ($catId in $teamPositions.Keys) {
                $pointsSource[$catId] = @{}
                $ordered = $teamPositions[$catId]
                for ($i = 0; $i -lt $ordered.Count; $i++) {
                    $pointsSource[$catId][$ordered[$i].Club] = $ordered.Count - $i
                }
            }
        }

    } elseif ($is2010Format) {

        # 2010: single Teams sheet holds all categories; no Tables/season-totals sheet.
        Write-Host "Parsing Teams sheet (2010)..." -ForegroundColor DarkGray
        $teamSheet2010 = $wb.Sheets | Where-Object { $_.Name -imatch '^teams?$' } | Select-Object -First 1
        $teams2010     = Parse-Teams2010 $teamSheet2010 $categoryIds
        $teamScorers   = $teams2010.Scorers
        $teamPositions = $teams2010.Positions
        Write-Host "  Team categories: $($teamPositions.Keys -join ', ')"

        # Derive per-race points from finishing positions (no season totals sheet in 2010)
        Write-Host "  Deriving season-totals points from team positions..." -ForegroundColor DarkGray
        $pointsSource = @{}
        foreach ($catId in $teamPositions.Keys) {
            $pointsSource[$catId] = @{}
            $ordered = $teamPositions[$catId]
            for ($i = 0; $i -lt $ordered.Count; $i++) {
                $pointsSource[$catId][$ordered[$i].Club] = $ordered.Count - $i
            }
        }

    } elseif ($isLegacyFormat) {

        # 2015: Teams sheet contains both scorer details and team positions;
        #       Tables sheet (or "master") contains per-race season totals.
        Write-Host "Parsing Teams sheet (2015)..." -ForegroundColor DarkGray
        $teamSheet   = $wb.Sheets.Item("Teams")
        $teams2015   = Parse-Teams2015 $teamSheet $categoryIds
        $teamScorers = $teams2015.Scorers
        $teamPositions = $teams2015.Positions
        Write-Host "  Team categories: $($teamPositions.Keys -join ', ')"

        Write-Host "Parsing Tables sheet (2015)..." -ForegroundColor DarkGray
        $tablesSheet  = $wb.Sheets | Where-Object { $_.Name -ieq "Tables" -or $_.Name -ieq "master" } | Select-Object -First 1
        if (-not $tablesSheet) { throw "Tables or master sheet not found" }
        $seasonTotals = Parse-SeasonTotals2015 $tablesSheet $RaceId

        if ($seasonTotals -and $seasonTotals.Count -gt 0) {
            Write-Host "  Season-totals categories: $($seasonTotals.Keys -join ', ')"
            $pointsSource = $seasonTotals

            # Cross-check Tables points vs Teams positions order (ordering only — total clubs may vary by category)
            Write-Host "  Cross-checking Tables points vs Teams positions..." -ForegroundColor DarkGray
            $crossErr = 0
            foreach ($catId in $teamPositions.Keys) {
                if (-not $seasonTotals.ContainsKey($catId)) { continue }
                $ordered  = $teamPositions[$catId]
                $prevPts  = [int]::MaxValue
                for ($i = 0; $i -lt $ordered.Count; $i++) {
                    $clubId    = $ordered[$i].Club
                    $actualPts = if ($seasonTotals[$catId].ContainsKey($clubId)) { $seasonTotals[$catId][$clubId] } else { 0 }
                    if ($actualPts -gt $prevPts) {
                        Write-Warning "    Cross-check ordering: $catId rank $($i+1) ($clubId, $actualPts pts) > rank $i ($prevPts pts)"
                        $crossErr++
                    }
                    $prevPts = $actualPts
                }
            }
            if ($crossErr -eq 0) { Write-Host "    All cross-checks passed" -ForegroundColor Green }
        } else {
            Write-Host "  Tables unavailable - deriving points from Teams positions" -ForegroundColor Yellow
            $pointsSource = @{}
            foreach ($catId in $teamPositions.Keys) {
                $pointsSource[$catId] = @{}
                $ordered = $teamPositions[$catId]
                for ($i = 0; $i -lt $ordered.Count; $i++) {
                    $pointsSource[$catId][$ordered[$i].Club] = $ordered.Count - $i
                }
            }
        }

    } else {

        # Current format: three separate sheets
        Write-Host "Parsing Team Scorers..." -ForegroundColor DarkGray
        $scorersSheet = $wb.Sheets.Item("Team Scorers")
        $teamScorers  = Parse-TeamScorers $scorersSheet
        Write-Host "  Categories: $($teamScorers.Keys -join ', ')"

        Write-Host "Parsing Team Positions..." -ForegroundColor DarkGray
        $positionsSheet = $wb.Sheets.Item("Team Positions")
        $teamPositions  = Parse-TeamPositions $positionsSheet
        Write-Host "  Categories: $($teamPositions.Keys -join ', ')"

        Write-Host "Parsing Season Totals..." -ForegroundColor DarkGray
        $totalsSheet  = $wb.Sheets.Item("Season Totals")
        $seasonTotals = Parse-SeasonTotals $totalsSheet $RaceId

        if ($seasonTotals -and $seasonTotals.Count -gt 0) {
            Write-Host "  Categories: $($seasonTotals.Keys -join ', ')"
            $pointsSource = $seasonTotals

            Write-Host "  Cross-checking Season Totals vs Team Positions..." -ForegroundColor DarkGray
            $crossErr = 0
            foreach ($catId in $teamPositions.Keys) {
                if (-not $seasonTotals.ContainsKey($catId)) { continue }
                $ordered = $teamPositions[$catId]
                for ($i = 0; $i -lt $ordered.Count; $i++) {
                    $expectedPts = $ordered.Count - $i
                    $clubId      = $ordered[$i].Club
                    $actualPts   = if ($seasonTotals[$catId].ContainsKey($clubId)) { $seasonTotals[$catId][$clubId] } else { 0 }
                    if ($expectedPts -ne $actualPts) {
                        Write-Warning "    Cross-check mismatch: $catId / $clubId expected $expectedPts pts (rank $($i+1)), got $actualPts from Season Totals"
                        $crossErr++
                    }
                }
            }
            if ($crossErr -eq 0) { Write-Host "    All cross-checks passed" -ForegroundColor Green }
        } else {
            Write-Host "  Season Totals unavailable - deriving points from Team Positions" -ForegroundColor Yellow
            $pointsSource = @{}
            foreach ($catId in $teamPositions.Keys) {
                $pointsSource[$catId] = @{}
                $ordered = $teamPositions[$catId]
                for ($i = 0; $i -lt $ordered.Count; $i++) {
                    $pointsSource[$catId][$ordered[$i].Club] = $ordered.Count - $i
                }
            }
        }
    }

    # ── 6. Build output JSON ───────────────────────────────────────────────
    Write-Host ""
    Write-Host "Building team results JSON..." -ForegroundColor DarkGray
    $teamsJson    = Build-TeamResultsJson $teamPositions $teamScorers $categoryIds $clubIds
    $teamsJsonStr = $teamsJson | ConvertTo-Json -Depth 10

    Write-Host "Building team standings JSON..." -ForegroundColor DarkGray
    $newStandings    = Update-TeamStandings `
        -StandingsPath  $standingsFile `
        -RaceId         $RaceId `
        -PointsSource   $pointsSource `
        -AllClubs       $clubIds `
        -AllCategories  $categoryIds `
        -IsProvisional  ([bool]$Provisional)
    $standingsJsonStr = $newStandings | ConvertTo-Json -Depth 10

    # ── 7. Write files ─────────────────────────────────────────────────────
    Write-Host ""
    if ($DryRun) {
        Write-Host "DRY RUN - files NOT written" -ForegroundColor Magenta
        $rowCount = $csvLines.Count - 1
        Write-Host "  Would write: $csvFile  ($rowCount data rows)"
        Write-Host "  Would write: $teamsFile"
        Write-Host "  Would write: $standingsFile"
        Write-Host "  Would copy:  $ExcelFile -> $xlsxDest"
        Write-Host ""
        Write-Host "CSV preview (first 6 lines):" -ForegroundColor Yellow
        $csvLines | Select-Object -First 6 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    } else {
        if (-not (Test-Path $resultsDir)) {
            New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
        }

        ($csvLines -join "`n") | Set-Content -Path $csvFile -Encoding UTF8 -NoNewline
        Write-Host "Written: $csvFile" -ForegroundColor Green

        $teamsJsonStr | Set-Content -Path $teamsFile -Encoding UTF8
        Write-Host "Written: $teamsFile" -ForegroundColor Green

        $standingsJsonStr | Set-Content -Path $standingsFile -Encoding UTF8
        Write-Host "Written: $standingsFile" -ForegroundColor Green

        if ($ExcelFile -ne $xlsxDest) {
            Copy-Item -Path $ExcelFile -Destination $xlsxDest -Force
            Write-Host "Copied:  $xlsxDest" -ForegroundColor Green
        } else {
            Write-Host "Skipped copy: Excel file already in results directory" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    if ($errCount -gt 0) {
        Write-Host "Completed with $errCount validation warning(s) - review above." -ForegroundColor Yellow
    } else {
        Write-Host "Completed successfully." -ForegroundColor Green
    }

} finally {
    $wb.Close($false)
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wb)    | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
}
