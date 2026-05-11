const fs = require('fs');
const path = require('path');

// Helper function to map club names to club IDs
const clubNameMap = {
  'blackpool': 'blackpool',
  'blackpool wyre': 'blackpool',
  'chorley': 'chorley',
  'lytham': 'lytham',
  'lytham st annes': 'lytham',
  'preston': 'preston',
  'red rose': 'red-rose',
  'wesham': 'wesham',
  'thornton': 'thornton'
};

function mapClubName(name) {
  const normalized = name.toLowerCase().trim();
  for (const [key, value] of Object.entries(clubNameMap)) {
    if (normalized.includes(key)) return value;
  }
  return normalized;
}

function parseCategory(categoryStr) {
  const cat = categoryStr.trim().toUpperCase();

  // Extract age category
  let ageCategory = 'SEN';
  let sex = '';

  if (cat.startsWith('M')) {
    sex = 'M';
    if (cat.includes('70')) ageCategory = 'V70';
    else if (cat.includes('60')) ageCategory = 'V60';
    else if (cat.includes('55')) ageCategory = 'V55';
    else if (cat.includes('50')) ageCategory = 'V50';
    else if (cat.includes('45')) ageCategory = 'V45';
    else if (cat.includes('40')) ageCategory = 'V40';
  } else if (cat.startsWith('F')) {
    sex = 'F';
    if (cat.includes('70')) ageCategory = 'V70';
    else if (cat.includes('60')) ageCategory = 'V60';
    else if (cat.includes('55')) ageCategory = 'V55';
    else if (cat.includes('50')) ageCategory = 'V50';
    else if (cat.includes('45')) ageCategory = 'V45';
    else if (cat.includes('40')) ageCategory = 'V40';
  } else if (cat === 'MS' || cat === 'M' || cat === 'MSEN') {
    sex = 'M';
    ageCategory = 'SEN';
  } else if (cat === 'FS' || cat === 'F' || cat === 'FSEN') {
    sex = 'F';
    ageCategory = 'SEN';
  } else if (cat === 'WSEN') {
    sex = 'F';
    ageCategory = 'SEN';
  }

  return { sex, ageCategory };
}

// Parse the extracted text
const textFile = 'C:\\Users\\wheel\\.claude\\projects\\C--Users-wheel-source-repos-InterClub--claude-worktrees-happy-wozniak-4bfa68\\72c49013-eb2b-4645-b32e-8211435ec2fb\\tool-results\\bcpfsfgj7.txt';
const text = fs.readFileSync(textFile, 'utf-8');

// Race definitions
const races = [
  { id: 'cake-race', name: 'Cake Race', startMarker: 'Cake Race', endMarker: 'Two Lads Fell Race' },
  { id: 'walsh-two-lads', name: 'Two Lads Fell Race', startMarker: 'Two Lads Fell Race', endMarker: 'Bull Hill Fell Race' },
  { id: 'bull-hill', name: 'Bull Hill Fell Race', startMarker: 'Bull Hill Fell Race', endMarker: 'Boulsworth Fell Race' },
  { id: 'boulsworth', name: 'Boulsworth Fell Race', startMarker: 'Boulsworth Fell Race', endMarker: 'Inter Club Fell Series 2017' }
];

// Parse Race 1 & 2 (formatted tables)
function parseTableRace(raceText, raceId) {
  const lines = raceText.split('\n').map(l => l.trim()).filter(l => l);
  const results = [];

  // Skip header section until we find the first data entry
  let dataStartIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    // Look for lines that start with a number followed by a name
    if (/^\d+\s+[A-Z]/.test(lines[i])) {
      dataStartIdx = i;
      break;
    }
  }

  if (dataStartIdx === -1) return [];

  // Parse multi-line entries
  let i = dataStartIdx;
  let icPosition = 1;

  while (i < lines.length) {
    const line = lines[i];

    // Check if this is end of race data
    if (line.match(/^(Two Lads|Bull Hill|Boulsworth|Overall|Inter Club)/)) break;

    // Parse a runner entry - might be multiple lines
    // Line format: position name club category time (and extra columns for team)
    const parts = line.split(/\s+/);

    if (parts.length < 5) {
      i++;
      continue;
    }

    try {
      const position = parseInt(parts[0]);
      if (isNaN(position)) {
        i++;
        continue;
      }

      // Combine remaining parts to find the structure
      // Format: POS NAME CLUB CAT TIME OVERALL ...
      // We need to find where name ends and club begins

      let nameEndIdx = 1;
      let nameStr = parts[1];

      // Try to identify the pattern - club names are specific
      let clubIdx = -1;
      for (let j = 2; j < parts.length; j++) {
        const potential = parts.slice(2, j + 1).join(' ').toLowerCase();
        if (clubNameMap[potential] || ['blackpool', 'chorley', 'lytham', 'preston', 'red', 'wesham', 'thornton'].some(c => potential.includes(c))) {
          clubIdx = j;
          nameEndIdx = j - 2;
          break;
        }
      }

      if (clubIdx === -1) {
        i++;
        continue;
      }

      // Extract components
      nameStr = parts.slice(1, clubIdx - 1).join(' ');
      const clubStr = parts.slice(clubIdx - 1, clubIdx + 1).join(' ');
      const categoryStr = parts[clubIdx + 2];
      const timeStr = parts[clubIdx + 3];
      const overallPos = parts[clubIdx + 4] ? parseInt(parts[clubIdx + 4]) : icPosition;

      // Split name
      const nameParts = nameStr.split(/\s+/);
      const firstName = nameParts[0];
      const lastName = nameParts.slice(1).join(' ');

      const { sex, ageCategory } = parseCategory(categoryStr);
      const clubId = mapClubName(clubStr);

      results.push({
        position,
        ic_position: overallPos,
        race_number: position,
        first_name: firstName,
        last_name: lastName,
        club: clubId,
        category: ageCategory,
        sex,
        time: timeStr
      });

      icPosition = overallPos + 1;
    } catch (e) {
      // Skip parsing errors
    }

    i++;
  }

  return results;
}

// Extract race sections
for (const race of races) {
  const startIdx = text.indexOf(race.startMarker);
  const endIdx = text.indexOf(race.endMarker, startIdx);

  if (startIdx === -1) {
    console.log(`Warning: Could not find race: ${race.id}`);
    continue;
  }

  const raceText = endIdx === -1 ? text.substring(startIdx) : text.substring(startIdx, endIdx);

  let results = [];

  if (race.id === 'cake-race' || race.id === 'walsh-two-lads') {
    results = parseTableRace(raceText, race.id);
  } else {
    console.log(`Race ${race.id} requires custom parsing`);
  }

  // Write CSV
  if (results.length > 0) {
    const headers = ['position', 'ic_position', 'race_number', 'first_name', 'last_name', 'club', 'category', 'sex', 'time'];
    const rows = results.map(r => [
      r.position,
      r.ic_position,
      r.race_number,
      r.first_name,
      r.last_name,
      r.club,
      r.category,
      r.sex,
      r.time
    ]);

    const csv = [headers, ...rows.map(r => r.join(','))].join('\n');
    const outputPath = `src/data/2017/fell/results/${race.id}.csv`;

    fs.writeFileSync(outputPath, csv);
    console.log(`✓ Created ${outputPath} with ${results.length} runners`);
  }
}
