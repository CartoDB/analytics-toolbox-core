const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ST_MINKOWSKIDISTANCE should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(0,0))::STRING, ST_ASGEOJSON(ST_POINT(1,0))::STRING), 2) as minkowskidistance1,
               @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(0,0))::STRING, ST_ASGEOJSON(ST_POINT(100,0))::STRING), 2) as minkowskidistance2,
               @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(0,0))::STRING, ST_ASGEOJSON(ST_POINT(10,10))::STRING), 2) as minkowskidistance3,
               @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(0,0))::STRING, ST_ASGEOJSON(ST_POINT(10,10))::STRING), 1) as minkowskidistance4
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].MINKOWSKIDISTANCE1).toEqual([[0,1],[1,0]]);
    expect(rows[0].MINKOWSKIDISTANCE2).toEqual([[0,0.01],[0.01,0]]);
    expect(rows[0].MINKOWSKIDISTANCE3).toEqual([[0,0.07071067811865475],[0.07071067811865475,0]]);
    expect(rows[0].MINKOWSKIDISTANCE4).toEqual([[0,0.05],[0.05,0]]);
});

test('ST_MINKOWSKIDISTANCE should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(NULL, 2) as minkowskidistance1
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].MINKOWSKIDISTANCE1).toEqual([]);
});

test('ST_MINKOWSKIDISTANCE default values should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-3.70325 ,40.4167))::STRING, ST_ASGEOJSON(ST_POINT(-5.70325 ,40.4167))::STRING), 2) as defaultValue,
               @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-3.70325 ,40.4167))::STRING, ST_ASGEOJSON(ST_POINT(-5.70325 ,40.4167))::STRING), NULL) as nullParam
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].NULLPARAM).toEqual(rows[0].DEFAULTVALUE);
});