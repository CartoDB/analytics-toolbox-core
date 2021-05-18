const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_GREATCIRCLE should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 10), 11) as greatcircle1,
    \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(ST_GEOGPOINT(-1.70325, 1.4167), ST_GEOGPOINT(1.70325, -1.4167), 5) as greatcircle2,
    \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(ST_GEOGPOINT(5, 5), ST_GEOGPOINT(-5, -5), 9) as greatcircle3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].greatcircle1.value).toEqual('LINESTRING(0 0, 0 1, 0 2, 0 3, 0 4, 0 5, 0 6, 0 7, 0 8, 0 9, 0 10)');
    expect(rows[0].greatcircle2.value).toEqual('LINESTRING(-1.70325 1.4167, -0.851494810735767 0.708428246541401, 0 0, 0.851494810735767 -0.708428246541401, 1.70325 -1.4167)');
    expect(rows[0].greatcircle3.value).toEqual('LINESTRING(5 5, 4.68645634383906 4.68802077037542, 4.37291268767811 4.37604154075084, 4.05936903151717 4.06406231112625, 3.74582537535623 3.75208308150167, 3.43317685113302 3.43965698065784, 3.12052832690981 3.12723087981402, 2.80787980268661 2.81480477897019, 2.4952312784634 2.50237867812637, 1.87112584142468 1.8769323037568, 1.24702040438596 1.25148592938724, 0.623510202192982 0.625742964693619, 0 0, -0.623510202192982 -0.625742964693619, -1.24702040438596 -1.25148592938724, -1.87112584142468 -1.8769323037568, -2.4952312784634 -2.50237867812637, -2.80787980268661 -2.81480477897019, -3.12052832690981 -3.12723087981402, -3.43317685113302 -3.43965698065784, -3.74582537535623 -3.75208308150167, -4.05936903151717 -4.06406231112625, -4.37291268767811 -4.37604154075084, -4.68645634383906 -4.68802077037542, -5 -5)');
});

test('ST_GREATCIRCLE should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(NULL, ST_GEOGPOINT(-73.9385,40.6643), 20) as greatcircle1,
    \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(ST_GEOGPOINT(-3.70325,40.4167), NULL, 20) as greatcircle2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].greatcircle1).toEqual(null);
    expect(rows[0].greatcircle2).toEqual(null);
});

test('ST_GREATCIRCLE default values should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(ST_GEOGPOINT(-3.70325,40.4167), ST_GEOGPOINT(-73.9385,40.6643), 100) as defaultValue,
    \`@@BQ_PREFIX@@transformations.ST_GREATCIRCLE\`(ST_GEOGPOINT(-3.70325,40.4167), ST_GEOGPOINT(-73.9385,40.6643), NULL) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam1).toEqual(rows[0].defaultValue);
});