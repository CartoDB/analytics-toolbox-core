/* Util functions */
function almostEquals(x, y, epsilon = 0.001) {
    return Math.abs(x - y) < epsilon;
}

function assertAlmostEqual(t, actual, expected, epsilon = 0.001, msg) {
    t.ok(almostEquals(actual, expected, epsilon), `${msg} ${actual} vs ${expected}`);
}

/* Placekey tests */
const fs = require('fs');
const test = require('tape-promise/tape');

/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../placekey_library.js') + '');
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
