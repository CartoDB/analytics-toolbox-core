const { runQuery } = require('../../../../../common/bigquery/test-utils');

const pointFixturesIn = require('./buffer_fixtures/in/point');
const pointFixturesOut = require('./buffer_fixtures/out/point');

test('ST_BUFFER should work', async () => {
    const featureJSON = JSON.stringify(pointFixturesIn.geom.geometry);
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', 10) as buffer;`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].buffer.value).toEqual(pointFixturesOut.value);
});

test('ST_BUFFER should return NULL if any NULL mandatory argument', async () => {
    const feature = {
        'type': 'Point',
        'coordinates': [-100, 50]  
    };
    const featureJSON = JSON.stringify(feature);

    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(NULL, 1, 'kilometers', 10) as buffer1,
    \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), CAST(NULL AS FLOAT64), 'kilometers', 10) as buffer2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].buffer1).toEqual(null);
    expect(rows[0].buffer2).toEqual(null);
});

test('ST_BUFFER default values should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(ST_GEOGPOINT(-74.00, 40.7128), 1, "kilometers", 8) as defaultValue,
    \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(ST_GEOGPOINT(-74.00, 40.7128), 1, NULL, NULL) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam1).toEqual(rows[0].defaultValue);
});

test('ST_BUFFER should fail with wrong arguments', async () => {
    const feature = {
        'type': 'Point',
        'coordinates': [-100, 50]  
    };
    const featureJSON = JSON.stringify(feature);
    
    let query = `SELECT \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), -1, 'kilometers', 10);`;
    await expect(runQuery(query)).rejects.toThrow(
        'TypeError: Cannot read property \'geometry\' of undefined at UDF$1(STRING, FLOAT64, STRING, INT64) line 15, columns 33-34'
    );

    query = `SELECT \`@@BQ_PREFIX@@transformations.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', -10);`;
    await expect(runQuery(query)).rejects.toThrow();
});
