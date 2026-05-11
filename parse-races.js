const fs = require('fs');

const text = fs.readFileSync('C:\\Users\\wheel\\.claude\\projects\\C--Users-wheel-source-repos-InterClub--claude-worktrees-happy-wozniak-4bfa68\\72c49013-eb2b-4645-b32e-8211435ec2fb\\tool-results\\bcpfsfgj7.txt', 'utf-8');

// Map full club names to IDs
const clubMap = {
  'blackpool wyre & fylde ac': 'blackpool',
  'blackpool': 'blackpool',
  'chorley a&tc': 'chorley',
  'chorley': 'chorley',
  'lytham st annes rr': 'lytham',
  'lytham': 'lytham',
  'preston harriers': 'preston',
  'preston': 'preston',
  'red rose road runners': 'red-rose',
  'red rose': 'red-rose',
  'thornton cleveleys rc': 'thornton',
  'thornton': 'thornton',
  'wesham road runners': 'wesham',
  'wesham': 'wesham'
};

function getClubId(name) {
  const lower = name.toLowerCase().trim();
  return clubMap[lower] || lower.replace(/\s+/g, '-');
}

function parseCategory(cat) {
  cat = cat.toUpperCase().trim();
  let sex = '';
  let ageCategory = 'SEN';

  if (cat.startsWith('M')) {
    sex = 'M';
  } else if (cat.startsWith('F') || cat.startsWith('W')) {
    sex = 'F';
  }

  // Determine age category
  if (cat.match(/70/)) ageCategory = 'V70';
  else if (cat.match(/60|6\d/)) ageCategory = 'V60';
  else if (cat.match(/50|5\d/)) ageCategory = 'V50';
  else if (cat.match(/40|4\d/)) ageCategory = 'V40';

  return { sex, ageCategory };
}

// Parse Race 1 - Cake Race (lines 7-730)
const cakeRaceData = `
7 Darren Fishwick Chorley M45 01:11:20 1
8 Oliver Heaton Preston M 01:11:56 2
11 Andrew Harrison Preston M 01:14:02 3
13 Joe Greenwood Lytham M 01:14:12 4
15 David Parkington Preston M50 01:14:49 5
29 Joanna Goorney Lytham F45 01:19:19 6
35 Andrew Christie Red Rose M 01:20:34 7
36 John Griffiths Preston M50 01:21:17 8
37 Andrew Grimshaw Preston M 01:21:21 9
45 Philip Butler Red Rose M50 01:21:50 10
52 Lynne Clough Chorley F45 01:23:17 11
55 Chris Charnley Chorley M40 01:23:42 12
58 Frank Nightingale Red Rose M50 01:24:02 13
60 Roger Taylor Preston M45 01:24:12 14
69 Stuart Cann Red Rose M50 01:25:59 15
71 Mark Ellithorn Chorley M50 01:26:25 16
72 Barry Wheeler Red Rose M 01:26:31 17
77 Stephen Bonsu Preston M40 01:27:15 18
90 Gary Corcoran Red Rose M45 01:28:57 19
92 Nigel Shepherd Wesham M55 01:29:01 20
93 Roy Parkinson Preston M50 01:29:02 21
95 John Collier Wesham M60 01:29:19 22
103 Sarah Sherratt Wesham F45 01:30:51 23
121 Michael McLoughlin Preston M60 01:33:49 24
122 David Miller Chorley M60 01:34:57 25
132 Peter Carter Preston M50 01:36:24 26
138 Steve Taylor Preston M60 01:36:46 27
155 Stephen Barker Chorley M55 01:39:10 28
158 Debbie Cooper Lytham F40 01:39:25 29
180 Stephen Robertson Red Rose M55 01:43:09 30
184 Paula Plowman Red Rose F50 01:43:51 31
190 Martin Simpson Red Rose M 01:44:53 32
197 Lynn Melvin Red Rose F55 01:46:45 33
200 Laura Marie Lawler Blackpool F45 01:47:15 34
205 Simon Scarr Blackpool M50 01:47:41 35
208 Antony Walton Red Rose M 01:47:48 36
209 Chris Patterson Red Rose M45 01:47:50 37
210 Francisco Concepcion Red Rose M45 01:48:04 38
220 Alan Wilkinson Blackpool M65 01:51:52 39
232 Pete McDermott Preston M70 01:55:38 40
237 Alison Mercer Red Rose F55 01:57:59 41
243 Alistair Morris Wesham M55 01:59:25 42
247 J Wright Blackpool F55 02:01:48 43
251 Olga Wiggins Preston F 02:02:21 44
252 Debbie Porter Red Rose F45 02:02:30 45
256 Greg Oulton Lytham M45 02:04:17 46
258 Paul Jackson Chorley M50 02:05:37 47
268 David Roberts Preston M70 02:17:33 48
273 Mary Conway Red Rose F55 02:18:14 49
274 Sue Tonge Red Rose F60 02:18:14 50
275 Cathy Karn Red Rose F50 02:18:14 51
276 Sally Cape Red Rose F50 02:18:14 52
277 Jenny Fairclough Red Rose F55 02:18:14 53
278 Peter Richard Gibson Blackpool M60 02:18:59 54
`;

// Parse Race 2 - Two Lads (partial data shown)
const twoLadsData = `
6 Richard Smith Preston MS 00:36:03 1
8 Jame Simon Red Rose MS 00:36:06 2
9 Duncan Anderson Red Rose MS 00:36:09 3
12 Darren Fishwick Chorley M45 00:36:50 4
15 Simon Collins Preston MS 00:36:58 5
17 Toney Donnelly Preston MS 00:37:24 6
18 Daniel Hughes Red Rose MS 00:37:36 7
22 Chris Charnley Chorley M40 00:39:22 8
29 Andrew Christie Red Rose MS 00:40:13 9
33 John Griffiths Preston M50 00:40:35 10
35 Paul Gregory Wesham MS 00:40:42 11
39 Mark Ellithorn Chorley M50 00:41:13 12
48 Andy Whaley Preston M40 00:41:51 13
50 Steve Myerscough Wesham M40 00:41:58 14
51 Frank Nightingale Red Rose M50 00:42:05 15
60 John Naylor Red Rose MS 00:43:07 16
65 Bill Beckett Chorley M50 00:44:08 17
70 Gary Corcoran Red Rose M45 00:45:07 18
72 Philip Butler Red Rose M50 00:45:21 19
74 Adrian Pilkington Chorley M45 00:45:24 20
75 Roy Parkinson Preston M50 00:45:39 21
76 Andy Hale Red Rose M40 00:45:42 22
79 John Collier Wesham M60 00:45:50 23
80 Nigel Shepherd Wesham M55 00:45:51 24
83 Alan Appleby Preston M65 00:46:18 25
94 David Miller Chorley M60 00:47:44 26
96 Martin Bates Wesham M60 00:47:55 27
97 Steven Willetts Red Rose MS 00:47:57 28
98 Mike Burnham Preston MS 00:47:59 29
101 Stephen Baker Chorley M55 00:48:41 30
106 Peter Bolton Red Rose M55 00:49:46 31
108 Debbie Cooper Lytham F40 00:49:58 32
109 Martin Quinn Chorley M40 00:50:35 33
112 Steve Taylor Preston M60 00:51:08 34
113 David North Chorley M55 00:51:14 35
116 Jen Salt Wesham F40 00:51:59 36
120 Simon Morris Red Rose M40 00:53:07 37
122 Chris Patterson Red Rose M45 00:53:24 38
123 Vicki Sherrington Preston F45 00:53:47 39
125 Paula Plowman Red Rose F50 00:53:54 40
128 Andrew Lowe Chorley M55 00:54:24 41
129 Martin Simpson Red Rose MS 00:54:39 42
130 Simon Scarr Blackpool M50 00:54:47 43
131 Julia Rolfe Lytham F50 00:55:04 44
132 Alan Wilkinson Blackpool M65 00:55:07 45
134 Graham Schofield Chorley M60 00:55:28 46
137 Susan Hawitt Lytham F50 00:56:26 47
139 Pete McDermott Preston M70 00:57:47 48
146 Pamela Hardman Lytham F55 00:58:52 49
147 Francsico Concepcion Red Rose M40 00:59:06 50
148 Alison Mercer Red Rose F55 00:59:11 51
151 Phil Lakeland Preston M60 01:01:45 52
153 Ruth Travis Red Rose F40 01:02:26 53
154 Olga Wiggins Preston FS 01:03:24 54
155 Greg Oulton Lytham M45 01:03:31 55
157 David Roberts Preston M70 01:04:23 56
158 Jenny Fairclough Red Rose F55 01:07:22 57
159 Colin Manning Red Rose MS 01:08:29 58
160 Paul Jackson Chorley M50 01:09:51 59
161 Dawn Lock Lytham F70 01:18:28 60
162 Lisa Hyde Red Rose F40 01:20:55 61
`;

function parseRaceData(data, raceId) {
  const results = [];
  const lines = data.trim().split('\n');

  for (const line of lines) {
    const parts = line.trim().split(/\s+/);
    if (parts.length < 7) continue;

    const bib = parts[0];
    const firstName = parts[1];
    const club = parts[2];
    const category = parts[3];
    const time = parts[4];
    const position = parseInt(parts[5]);

    if (isNaN(position)) continue;

    const { sex, ageCategory } = parseCategory(category);
    const clubId = getClubId(club);

    results.push({
      position,
      ic_position: position,
      race_number: bib,
      first_name: firstName,
      last_name: '', // No last names in this format
      club: clubId,
      category: ageCategory,
      sex,
      time
    });
  }

  return results;
}

// Process races
const races = [
  { id: 'cake-race', data: cakeRaceData },
  { id: 'walsh-two-lads', data: twoLadsData }
];

for (const race of races) {
  const results = parseRaceData(race.data, race.id);

  if (results.length === 0) continue;

  // Write CSV
  const headers = ['position', 'ic_position', 'race_number', 'first_name', 'last_name', 'club', 'category', 'sex', 'time'];
  const rows = results.map(r => [
    r.position,
    r.ic_position,
    r.race_number,
    `"${r.first_name}"`,
    `"${r.last_name}"`,
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
