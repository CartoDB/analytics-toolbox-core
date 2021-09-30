const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_BOUNDARY should work', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(12070922) as geog1,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(791040491538) as geog2,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(12960460429066265) as geog3`;
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(0) as geog4,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(1) as geog5,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(33) as geog6,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(65) as geog7,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(97) as geog8,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(2) as geog9,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(130) as geog10,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(258) as geog11,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(386) as geog12,
            \`@@BQ_PREFIX@@quadkey.ST_BOUNDARY\`(34) as geog13`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].geog1.value)).toEqual('"POLYGON((-45 45.089035564831, -45 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -45 45.089035564831))"');
    expect(JSON.stringify(rows[0].geog2.value)).toEqual('"POLYGON((-45 45.0007380782907, -45 44.9997670191813, -44.9986267089844 44.9997670191813, -44.9986267089844 45.0007380782907, -45 45.0007380782907))"');
    expect(JSON.stringify(rows[0].geog3.value)).toEqual('"POLYGON((-45 45.0000021990696, -45 44.9999946126367, -44.9999892711639 44.9999946126367, -44.9999892711639 45.0000021990696, -45 45.0000021990696))"');
    expect(JSON.stringify(rows[0].geog4.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog5.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog6.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog7.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog8.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog9.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog10.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog11.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog12.value)).toEqual('');
    expect(JSON.stringify(rows[0].geog13.value)).toEqual('');
});

test('ST_BOUNDARY should fail with NULL argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});