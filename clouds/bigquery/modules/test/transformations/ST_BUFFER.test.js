const { runQuery } = require('../../../common/test-utils');

const pointFixturesIn = require('./fixtures/st_buffer_in');
const pointFixturesOut = require('./fixtures/st_buffer_out');

test('ST_BUFFER should work', async () => {
    const featureJSON = JSON.stringify(pointFixturesIn.geom.geometry);
    const query = `SELECT \`@@BQ_DATASET@@.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', 10) as buffer;`;
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

    const query = `SELECT \`@@BQ_DATASET@@.ST_BUFFER\`(NULL, 1, 'kilometers', 10) as buffer1,
    \`@@BQ_DATASET@@.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), CAST(NULL AS FLOAT64), 'kilometers', 10) as buffer2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].buffer1).toEqual(null);
    expect(rows[0].buffer2).toEqual(null);
});

test('ST_BUFFER default values should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_BUFFER\`(ST_GEOGPOINT(-74.00, 40.7128), 1, "kilometers", 8) as defaultValue,
    \`@@BQ_DATASET@@.ST_BUFFER\`(ST_GEOGPOINT(-74.00, 40.7128), 1, NULL, NULL) as nullParam1`;
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
    
    let query = `SELECT \`@@BQ_DATASET@@.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), -1, 'kilometers', 10);`;
    await expect(runQuery(query)).rejects.toThrow();

    query = `SELECT \`@@BQ_DATASET@@.ST_BUFFER\`(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', -10);`;
    await expect(runQuery(query)).rejects.toThrow();
});

test('ST_BUFFER should not fail with geographies close to the poles', async () => {
    let query = 'SELECT `@@BQ_DATASET@@.ST_BUFFER`(ST_GEOGPOINT(90, 90), 1, "kilometers", 8);';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
});