const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADINT_TOGEOGPOINT should work', async () => {
    const query = `
        SELECT
            \`@@BQ_PREFIX@@carto.QUADINT_TOGEOGPOINT\`(12070922) as geog1,
            \`@@BQ_PREFIX@@carto.QUADINT_TOGEOGPOINT\`(791040491538) as geog2,
            \`@@BQ_PREFIX@@carto.QUADINT_TOGEOGPOINT\`(12960460429066265) as geog3`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);  
    expect(JSON.stringify(rows[0].geog1.value)).toEqual('"POINT(-44.82421875 44.964797930331)"');
    expect(JSON.stringify(rows[0].geog2.value)).toEqual('"POINT(-44.9993133544922 45.0002525507932)"');
    expect(JSON.stringify(rows[0].geog3.value)).toEqual('"POINT(-44.999994635582 44.9999984058533)"');
});