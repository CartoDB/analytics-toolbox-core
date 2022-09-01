const { runQuery } = require('../../../common/test-utils');

test('QUADINT_CENTER should work', async () => {
    const query = `
    SELECT
      \`@@BQ_DATASET@@.QUADINT_CENTER\`(quadint) boundary,
      quadint
    FROM
      UNNEST([0,1,2,33,34,65,97,130,258,386,12070922,791040491538,12960460429066265]) quadint
    ORDER BY
      quadint`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(13);
    expect(JSON.stringify(rows[0].boundary.value)).toEqual('"POINT(0 0)"');
    expect(JSON.stringify(rows[1].boundary.value)).toEqual('"POINT(-90 45)"');
    expect(JSON.stringify(rows[2].boundary.value)).toEqual('"POINT(-135 79.1713346408195)"');
    expect(JSON.stringify(rows[3].boundary.value)).toEqual('"POINT(90 45)"');
    expect(JSON.stringify(rows[4].boundary.value)).toEqual('"POINT(-45 79.1713346408195)"');
    expect(JSON.stringify(rows[5].boundary.value)).toEqual('"POINT(-90 -45)"');
    expect(JSON.stringify(rows[6].boundary.value)).toEqual('"POINT(90 -45)"');
    expect(JSON.stringify(rows[7].boundary.value)).toEqual('"POINT(-135 40.9798980696201)"');
    expect(JSON.stringify(rows[8].boundary.value)).toEqual('"POINT(-135 -40.9798980696201)"');
    expect(JSON.stringify(rows[9].boundary.value)).toEqual('"POINT(-135 -79.1713346408195)"');
    expect(JSON.stringify(rows[10].boundary.value)).toEqual('"POINT(-44.82421875 44.964797930331)"');
    expect(JSON.stringify(rows[11].boundary.value)).toEqual('"POINT(-44.9993133544922 45.0002525507932)"');
    expect(JSON.stringify(rows[12].boundary.value)).toEqual('"POINT(-44.999994635582 44.9999984058533)"');
});

test('QUADINT_CENTER should fail with NULL argument', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.QUADINT_CENTER`(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});