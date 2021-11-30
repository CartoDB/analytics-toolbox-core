const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('S2_IDFROMHILBERTQUADKEY should work', async () => {
    const query = `
        SELECT CAST(\`@@BQ_PREFIX@@carto.S2_IDFROMHILBERTQUADKEY\`(key) AS STRING) as id
        FROM UNNEST([
            '4/12', '2/02300033', '3/03131200023201', '5/0001221313222222120',
            '2/0221200002312111222332101', '5/1331022022103232320303230131'
        ]) as key
    `;
    const rows = await runQuery(query);
    expect(rows.map(r => r.id.toString())).toEqual([
        '-8286623314361712640', '5008548143403368448', '7416309021449125888',
        '-6902629179221606400', '4985491052606295040', '-5790199077674720336'
    ]);
});

test('S2_IDFROMHILBERTQUADKEY should fail with NULL argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.S2_IDFROMHILBERTQUADKEY`(NULL)';
    await expect(runQuery(query)).rejects.toThrow('NULL argument passed to UDF');
});