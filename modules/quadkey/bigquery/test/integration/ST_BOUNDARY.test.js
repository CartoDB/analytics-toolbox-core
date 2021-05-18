const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_BOUNDARY should work', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(12070922) as geog1,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(791040491538) as geog2,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(12960460429066265) as geog3`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);  
    expect(JSON.stringify(rows[0].geog1.value)).toEqual('"POLYGON((-45 45.089035564831, -45 44.840290651398, -44.82421875 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -44.82421875 45.089035564831, -45 45.089035564831))"');
    expect(JSON.stringify(rows[0].geog2.value)).toEqual('"POLYGON((-45 45.0007380782907, -45 44.9997670191813, -44.9986267089844 44.9997670191813, -44.9986267089844 45.0007380782907, -45 45.0007380782907))"');
    expect(JSON.stringify(rows[0].geog3.value)).toEqual('"POLYGON((-45 45.0000021990696, -45 44.9999946126367, -44.9999892711639 44.9999946126367, -44.9999892711639 45.0000021990696, -45 45.0000021990696))"'); 
});

test('ST_BOUNDARY should fail with NULL argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});