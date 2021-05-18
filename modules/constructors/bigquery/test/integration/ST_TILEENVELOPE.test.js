const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_TILEENVELOPE should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@constructors.ST_TILEENVELOPE\`(10, 384, 368) as geog1,
               \`@@BQ_PREFIX@@constructors.ST_TILEENVELOPE\`(18, 98304, 94299) as geog2,
               \`@@BQ_PREFIX@@constructors.ST_TILEENVELOPE\`(25, 12582912, 12070369) as geog3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].geog1.value).toEqual('POLYGON((-45 45.089035564831, -45 44.840290651398, -44.82421875 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -44.82421875 45.089035564831, -45 45.089035564831))');
    expect(rows[0].geog2.value).toEqual('POLYGON((-45 45.0007380782907, -45 44.9997670191813, -44.9986267089844 44.9997670191813, -44.9986267089844 45.0007380782907, -45 45.0007380782907))');
    expect(rows[0].geog3.value).toEqual('POLYGON((-45 45.0000021990696, -45 44.9999946126367, -44.9999892711639 44.9999946126367, -44.9999892711639 45.0000021990696, -45 45.0000021990696))');
});

test('ST_TILEENVELOPE should fail if any NULL argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(10, 384, null)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});