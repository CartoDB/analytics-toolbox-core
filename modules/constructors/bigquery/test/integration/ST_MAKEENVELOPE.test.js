const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_MAKEENVELOPE should work', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(10.0, 10.0, 11.0, 11.0) as poly1,
               \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(-179.0, 10.0, 179.0, 11.0) as poly2,
               \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(179.0, 10.0, -179.0, 11.0) as poly3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].poly1.value).toEqual('POLYGON((11 10, 11 11, 10 11, 10 10, 11 10))');
    expect(rows[0].poly2.value).toEqual('POLYGON((-179 10, -179 11, 179 11, 179 10, -179 10))');
    expect(rows[0].poly3.value).toEqual('POLYGON((-179 10, -179 11, 179 11, 179 10, -179 10))');
});

test('ST_MAKEENVELOPE should return NULL if any NULL argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(NULL, 10.0, 11.0, 11.0) as poly1,
               \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(10.0, NULL, 11.0, 11.0) as poly2,
               \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(10.0, 10.0, NULL, 11.0) as poly3,
               \`@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE\`(10.0, 10.0, 11.0, NULL) as poly4
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].poly1).toEqual(null);
    expect(rows[0].poly2).toEqual(null);
    expect(rows[0].poly3).toEqual(null);
    expect(rows[0].poly4).toEqual(null);
});