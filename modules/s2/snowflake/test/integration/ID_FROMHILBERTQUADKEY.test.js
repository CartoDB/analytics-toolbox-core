const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('ID_FROMHILBERTQUADKEY should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@s2.ID_FROMHILBERTQUADKEY(VALUE) as id
        FROM LATERAL FLATTEN(input => ARRAY_CONSTRUCT(
            '4/12', '2/02300033', '3/03131200023201', '5/0001221313222222120',
            '2/0221200002312111222332101', '5/1331022022103232320303230131'
        )) as key
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.ID.toString())).toEqual([
        '10160120759347838976', '5008548143403368448', '7416309021449125888',
        '11544114894487945216', '4985491052606295040', '12656544996034831280'
    ]);
});

test('ID_FROMHILBERTQUADKEY should fail with NULL argument', async () => {
    const query = 'SELECT @@SF_PREFIX@@s2.ID_FROMHILBERTQUADKEY(NULL)';
    await expect(runQuery(query)).rejects.toThrow('NULL argument passed to UDF');
});
