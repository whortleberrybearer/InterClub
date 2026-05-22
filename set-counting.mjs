import fs from 'fs';

const filePath = process.argv[2];
const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

// Race order determines tie-breaking (latest race = higher index)
const raceOrder = data.races;

data.categories.forEach(cat => {
  cat.runners.forEach(runner => {
    const raceEntries = Object.entries(runner.results);
    const raceCount = raceEntries.length;

    if (raceCount <= 2) {
      // 1 or 2 races: all non-counting
      raceEntries.forEach(([race, result]) => {
        result.counting = false;
      });
    } else if (raceCount === 3) {
      // Exactly 3 races: all counting
      raceEntries.forEach(([race, result]) => {
        result.counting = true;
      });
    } else if (raceCount === 4) {
      // 4 races: drop the lowest; if tied, drop the latest race
      const minPoints = Math.min(...raceEntries.map(([, r]) => r.points));
      const lowestRaces = raceEntries
        .filter(([, r]) => r.points === minPoints)
        .map(([race]) => race);

      // Pick the latest race among the lowest-scoring ones
      const nonCountingRace = lowestRaces.reduce((latest, race) => {
        return raceOrder.indexOf(race) > raceOrder.indexOf(latest) ? race : latest;
      });

      raceEntries.forEach(([race, result]) => {
        result.counting = race !== nonCountingRace;
      });
    }
  });
});

fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
console.log('Counting flags updated successfully');
