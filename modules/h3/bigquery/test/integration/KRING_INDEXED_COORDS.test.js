const { runQuery } = require('../../../../../common/bigquery/test-utils');


test('KRING_INDEXED_COORDS should work', async () => {
    const query = `
        WITH kring_data AS
        ( SELECT myrow,
            \`@@BQ_PREFIX@@h3.KRING_INDEXED_COORDS\`(idx, distance) as kring_elem,
        FROM UNNEST([
            STRUCT(1 as myrow, "invalid_index" as idx, 1 as distance),
            STRUCT(2, "8928308280fffff", NULL),
            STRUCT(3, "8928308280fffff", 1),
            STRUCT(4, "8928308280fffff", 3)
        ]))
        SELECT
        myrow,
        -- use STRING_AGG to deal with null
        STRING_AGG(CAST(ke.i as STRING) ORDER BY ke.idx) as kring_i,
        STRING_AGG(CAST(ke.j as STRING) ORDER BY ke.idx) as kring_j,
        STRING_AGG(CAST(ke.idx as STRING) ORDER BY ke.idx) as kring_idx
        FROM kring_data left join UNNEST(kring_elem) as ke
        GROUP BY myrow
    `;
    const myrows = await runQuery(query);
    expect(myrows.map(r => r.kring_i)).toEqual(
        [
            null,
            null,
            '-1,0,-1,0,1,0,1',
            '-1,0,-1,0,-2,-1,-2,2,3,2,3,1,2,1,-2,-1,-1,-3,-2,1,2,1,2,0,1,0,-3,-2,0,0,1,-1,-3,-3,0,3,3'
        ]);
    expect(myrows.map(r => r.kring_j)).toEqual(
        [
            null,
            null,
            '0,1,-1,0,1,-1,0',
            '0,1,-1,0,0,1,-1,2,3,1,2,2,3,1,-3,-2,-3,-3,-2,-1,0,-2,-1,-1,0,-2,0,1,3,2,3,2,-1,-2,-3,1,0'
        ]);

    expect(myrows.map(r => r.kring_idx)).toEqual(
        [
            null,
            null,
            '89283082803ffff,89283082807ffff,8928308280bffff,8928308280fffff,8928308283bffff,89283082873ffff,89283082877ffff',
            '89283082803ffff,89283082807ffff,8928308280bffff,8928308280fffff,89283082813ffff,89283082817ffff,8928308281bffff,89283082823ffff,89283082827ffff,8928308282bffff,8928308282fffff,89283082833ffff,89283082837ffff,8928308283bffff,89283082843ffff,89283082847ffff,8928308284fffff,89283082853ffff,89283082857ffff,89283082863ffff,89283082867ffff,8928308286bffff,8928308286fffff,89283082873ffff,89283082877ffff,8928308287bffff,8928308288bffff,8928308288fffff,892830828a3ffff,892830828abffff,892830828afffff,892830828bbffff,892830828c7ffff,892830828cfffff,89283082ab7ffff,89283082b93ffff,89283082b9bffff'
        ]);
});

test('KRING_INDEXED_COORDS should fail with NULL argument', async () => {
    const query = `
        SELECT \`@@BQ_PREFIX@@h3.KRING_INDEXED_COORDS\`(NULL)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});