// Placekey tests

const fs = require('fs');
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('./h3-integer.js') +
    fs.readFileSync('../../placekey_library.js') + '');

const test = require('tape-promise/tape');
const assertAlmostEqual = require('./utils/assertions');

const SAMPLES = require('./data/example_geos.json');
const DISTANCE_SAMPLES = require('./data/example_distances.json');

const ADDITIONAL_PLACEKEYS = [
  '223-222@5yv-j8g-y5f', // Chevron - Error
  'zzw-222@5py-nnf-45f', // Walmart - Error
  '228-222@5w9-jb2-v9f', // Nordstrom - Error
  '223-223@5pv-bds-3h5' // Starbucks - Error
];

test('stringCleaning', t => {
  t.equal(cleanString('vjngr'), 'vjugu', 'clean overlapping bad words out of sequence order');
  t.equal(dirtyString('vjugu'), 'vjngr', 'dirty overlapping bad words out of sequence order');

  t.equal(cleanString('prngr'), 'pregr', 'clean overlapping bad words in sequence order');
  t.equal(dirtyString('pregr'), 'prngr', 'dirty overlapping bad words in sequence order');
  t.end();
});

test('stringCleaningReplace', t => {
  t.equal(cleanString('prnprn'), 'prepre', 'clean bad words duplicated');
  t.equal(dirtyString('prepre'), 'prnprn', 'dirty bad words duplicated');
  t.end();
});

test('placekeyIsValid', t => {
  t.ok(placekeyIsValid('abc-234-xyz'), 'where with no @');
  t.ok(placekeyIsValid('@abc-234-xyz'), 'where with @');
  t.ok(placekeyIsValid('bcd-2u4-xez'), 'where with no replacement characters');
  t.ok(placekeyIsValid('zzz@abc-234-xyz'), 'single tuple what with where');
  t.ok(placekeyIsValid('222-zzz@abc-234-xyz'), 'double tuple what with where');

  t.notOk(placekeyIsValid('@abc'), 'short where part');
  t.notOk(placekeyIsValid('abc-xyz'), 'short where part');
  t.notOk(placekeyIsValid('abcxyz234'), 'no dashes');
  t.notOk(placekeyIsValid('abc-345@abc-234-xyz'), 'padding character in what');
  t.notOk(placekeyIsValid('ebc-345@abc-234-xyz'), 'replacement character in what');
  t.notOk(placekeyIsValid('bcd-345@'), 'missing what part');
  t.notOk(placekeyIsValid('22-zzz@abc-234-xyz'), 'short what part');
  t.end();
});

test('placekeyToH3', t => {
  for (const row of SAMPLES) {
    t.equal(
      placekeyToH3(row.placekey),
      row.h3_r10,
      `converted placekey (${row.placekey}) did not match h3 at resolution 10 (${row.h3_r10})`
    );
  }
  t.end();
});

test('placekeyToGeo', t => {
  const matchingPlaces = 3;
  for (const row of SAMPLES) {
    const [lat, long] = placekeyToGeo(row.placekey);
    assertAlmostEqual(
      t,
      lat,
      row.h3_lat,
      matchingPlaces,
      `placekey's latitude (${lat}) too far from associated geo's latitude (${row.h3_lat})`
    );
    assertAlmostEqual(
      t,
      long,
      row.h3_long,
      matchingPlaces,
      `placekey's longitude (${long}) too far from associated geo's longitude (${row.h3_long})`
    );
  }

  for (const placekey of ADDITIONAL_PLACEKEYS) {
    t.doesNotThrow(() => placekeyToH3(placekey));
  }

  t.end();
});

test('h3ToPlacekey', t => {
  for (const row of SAMPLES) {
    t.equal(
      h3ToPlacekey(row.h3_r10),
      row.placekey,
      `converted h3 (${row.h3_r10}) did not match placekey (${row.placekey})`
    );
  }
  t.end();
});

test('geoToPlacekey', t => {
  for (const row of SAMPLES) {
    const placekey = geoToPlacekey(row.lat, row.long);
    t.equal(
      placekey,
      row.placekey,
      `converted geo (${row.lat}, ${row.long}) did not match placekey (${row.placekey})`
    );
  }
  t.end();
});

test('placekeyToHexBoundary', t => {
  const key = '@5vg-7gq-tvz';
  const h3Form = placekeyToH3(key);
  t.deepEqual(
    placekeyToHexBoundary(key, true),
    h3ToGeoBoundary(h3Form, true),
    'placekey boundary equal to h3 boundary (geo_json=True)'
  );
  t.deepEqual(
    placekeyToHexBoundary(key, false),
    h3ToGeoBoundary(h3Form, false),
    'placekey boundary equal to h3 boundary (geo_json=False)'
  );
  t.end();
});

test('placekeyDistance', t => {
  t.equal(
    placekeyDistance(geoToPlacekey(0.0, 0.0), geoToPlacekey(0.0, 0.0)),
    0.0,
    'identical points have distance 0'
  );

  for (const sample of DISTANCE_SAMPLES) {
    assertAlmostEqual(
      t,
      placekeyDistance(sample.placekey_1, sample.placekey_2),
      sample.distance,
      0.1,
      `distances too far apart ${sample.placekey_1}, ${sample.placekey_2}`
    );
  }

  t.end();
});
