const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_GEOGPOINTFROMQUADINT should work', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT\`(12070922) as geog1,
            \`@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT\`(791040491538) as geog2,
            \`@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT\`(12960460429066265) as geog3`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);  
    expect(JSON.stringify(rows[0].geog1.value)).toEqual('"POINT(-44.82421875 50.283645114926)"');
    expect(JSON.stringify(rows[0].geog2.value)).toEqual('"POINT(-44.9993133544922 50.3082806407431)"');
    expect(JSON.stringify(rows[0].geog3.value)).toEqual('"POINT(-44.999994635582 50.308104008854)"');
});

test('ST_BOUNDARY should fail with NULL argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT`(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});