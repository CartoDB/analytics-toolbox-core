const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('QUADINT_BOUNDARY should work', async () => {
    const query = `
    SELECT
      \`@@BQ_PREFIX@@carto.QUADINT_BOUNDARY\`(quadint) boundary,
      quadint
    FROM
      UNNEST([0,1,2,33,34,65,97,130,258,386,12070922,791040491538,12960460429066265]) quadint
    ORDER BY
      quadint`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(13);
    expect(JSON.stringify(rows[1].boundary.value)).toEqual('"POLYGON((0 0, 0 85.0511287798066, -180 85.0511287798066, -180 0, -90 0, 0 0))"');
    expect(JSON.stringify(rows[2].boundary.value)).toEqual('"POLYGON((-180 85.0511287798066, -180 66.5132604431118, -90 66.5132604431118, -90 85.0511287798066, -180 85.0511287798066))"');
    expect(JSON.stringify(rows[3].boundary.value)).toEqual('"POLYGON((180 0, 180 85.0511287798066, 0 85.0511287798066, 0 0, 90 0, 180 0))"');
    expect(JSON.stringify(rows[4].boundary.value)).toEqual('"POLYGON((-90 85.0511287798066, -90 66.5132604431118, 0 66.5132604431118, 0 85.0511287798066, -90 85.0511287798066))"');
    expect(JSON.stringify(rows[5].boundary.value)).toEqual('"POLYGON((0 0, -90 0, 180 0, -180 -85.0511287798066, 0 -85.0511287798066, 0 0))"');
    expect(JSON.stringify(rows[6].boundary.value)).toEqual('"POLYGON((180 0, 90 0, 0 0, 0 -85.0511287798066, 180 -85.0511287798066, 180 0))"');
    expect(JSON.stringify(rows[7].boundary.value)).toEqual('"POLYGON((-180 66.5132604431118, -180 0, -90 0, -90 66.5132604431118, -180 66.5132604431118))"');
    expect(JSON.stringify(rows[8].boundary.value)).toEqual('"POLYGON((-180 0, -180 -66.5132604431119, -90 -66.5132604431119, -90 0, -180 0))"');
    expect(JSON.stringify(rows[9].boundary.value)).toEqual('"POLYGON((-180 -66.5132604431119, -180 -85.0511287798066, -90 -85.0511287798066, -90 -66.5132604431119, -180 -66.5132604431119))"');
    expect(JSON.stringify(rows[10].boundary.value)).toEqual('"POLYGON((-45 45.089035564831, -45 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -45 45.089035564831))"');
    expect(JSON.stringify(rows[11].boundary.value)).toEqual('"POLYGON((-45 45.0007380782907, -45 44.9997670191813, -44.9986267089844 44.9997670191813, -44.9986267089844 45.0007380782907, -45 45.0007380782907))"');
    expect(JSON.stringify(rows[12].boundary.value)).toEqual('"POLYGON((-45 45.0000021990696, -45 44.9999946126367, -44.9999892711639 44.9999946126367, -44.9999892711639 45.0000021990696, -45 45.0000021990696))"');
});

test('QUADINT_BOUNDARY should fail with NULL argument', async () => {
    const query = 'SELECT `@@BQ_PREFIX@@carto.QUADINT_BOUNDARY`(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});