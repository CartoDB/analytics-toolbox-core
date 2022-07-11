const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('__QUADBIN_FROMLONGLAT_ZOOMRANGE should work', async () => {
    const query = 'SELECT TO_JSON_STRING(`@@BQ_PREFIX@@carto.__QUADBIN_FROMLONGLAT_ZOOMRANGE`(40.4168, -3.7038, 3, 6, 1, 4)) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('[{"id":"5223073582220836863","z":3,"x":4,"y":4},{"id":"5227576975689777151","z":4,"x":9,"y":8},{"id":"5232080575317147647","z":5,"x":19,"y":16},{"id":"5236584162059616255","z":6,"x":39,"y":32}]');
});

test('__QUADBIN_FROMLONGLAT_ZOOMRANGE should return [] with NULL latitud/longitud', async () => {
    const query = `SELECT
         \`@@BQ_PREFIX@@carto.__QUADBIN_FROMLONGLAT_ZOOMRANGE\`(NULL, -3.7038, 3, 6, 1, 4) AS output0,
         \`@@BQ_PREFIX@@carto.__QUADBIN_FROMLONGLAT_ZOOMRANGE\`(40.4168, NULL, 3, 6, 1, 4) AS output1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output0).toEqual([]);
    expect(rows[0].output1).toEqual([]);
});