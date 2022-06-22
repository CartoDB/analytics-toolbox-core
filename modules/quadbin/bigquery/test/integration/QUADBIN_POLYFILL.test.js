const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADBIN_POLYFILL should work', async () => {
    const query = `SELECT TO_JSON_STRING(\`@@BQ_PREFIX@@carto.QUADBIN_POLYFILL\`(
        ST_MAKEPOLYGON(ST_MAKELINE([
            ST_GEOGPOINT(-363.71219873428345, 40.413365349070865),
            ST_GEOGPOINT(-363.7144088745117, 40.40965661286395),
            ST_GEOGPOINT(-363.70659828186035, 40.409525904775634),
            ST_GEOGPOINT(-363.71219873428345, 40.413365349070865)])),
        17)
    ) AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual('["5265786693153193983","5265786693163941887","5265786693164466175","5265786693164204031","5265786693164728319","5265786693165514751"]');
});