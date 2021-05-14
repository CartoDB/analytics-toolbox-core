const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('HILBERTQUADKEY_FROMID.test should work', async () => {
    const query = `
        SELECT @@SF_PREFIX@@s2.HILBERTQUADKEY_FROMID(id) as key
        FROM UNNEST([
            CAST('10160120759347838976' AS BIGINT), CAST('5008548143403368448' AS BIGINT),
            CAST('7416309021449125888' AS BIGINT), CAST('11544114894487945216' AS BIGINT),
            CAST('4985491052606295040' AS BIGINT), CAST('12656544996034831280' AS BIGINT)
        ]) as id
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.KEY)).toEqual([
        '4/12', '2/02300033', '3/03131200023201', '5/0001221313222222120',
        '2/0221200002312111222332101', '5/1331022022103232320303230131'
    ]);
});

test('HILBERTQUADKEY_FROMID should fail with NULL argument', async () => {
    const query = 'SELECT @@SF_PREFIX@@s2.HILBERTQUADKEY_FROMID(NULL)';
    await expect(runQuery(query)).rejects.toThrow('NULL argument passed to UDF');
});

