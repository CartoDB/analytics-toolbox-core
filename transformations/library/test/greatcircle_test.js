const fs = require('fs');
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../transformations_library.js') + '');
const test = require('tape');
const path = require('path');
const load = require('load-json-file');
const write = require('write-json-file');
const truncate = require("@turf/truncate").default;
const { featureCollection } = require("@turf/helpers");
const greatCircle = turf.greatCircle;

const directories = {
  in: path.join(__dirname, "greatcircle_test", "in") + path.sep,
  out: path.join(__dirname, "greatcircle_test", "out") + path.sep,
};

let fixtures = fs.readdirSync(directories.in).map((filename) => {
  return {
    filename,
    name: path.parse(filename).name,
    geojson: load.sync(path.join(directories.in, filename)),
  };
});

test("turf-great-circle", (t) => {
  fixtures.forEach((fixture) => {
    const name = fixture.name;
    const filename = fixture.filename;
    const geojson = fixture.geojson;
    const start = geojson.features[0];
    const end = geojson.features[1];
    const line = truncate(greatCircle(start, end));
    const results = featureCollection([line, start, end]);

    if (process.env.REGEN) write.sync(directories.out + filename, results);
    t.deepEquals(results, load.sync(directories.out + filename), name);
  });
  t.end();
});