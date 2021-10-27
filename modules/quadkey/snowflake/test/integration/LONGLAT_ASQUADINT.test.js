const { runQuery } = require('../../../../../common/snowflake/test-utils');

const quadintsFixturesOut = require('./longlat_asquadint_fixtures/out/quadints');

test('LONGLAT_ASQUADINT should not fail at any level of zoom', async () => {
    const query = `WITH zoomContext AS(
            WITH z AS
            (
                SELECT seq4() AS z
                FROM TABLE(generator(rowcount => 30))
            ),
            x AS
            (
            SELECT seq4() AS x
                FROM TABLE(generator(rowcount => 10))
            ),
            y as
            (
            SELECT seq4() AS y
                FROM TABLE(generator(rowcount => 10))
            )
            SELECT z as zoom,
            360*x/10-180 AS long,
            180*y/10-90 AS lat
            FROM z,x,y
            GROUP BY zoom,long,lat
        )
        SELECT *
        FROM 
        (
            SELECT ARRAY_AGG(LONGLAT_ASQUADINT(long, lat, zoom)) as quadints
            FROM zoomContext
        )`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].QUADINTS.sort()).toEqual(quadintsFixturesOut.value);
});

test('Should fail to encode quadints at zooms bigger than 29 or smaller than 0', async () => {
    let query = 'SELECT LONGLAT_ASQUADINT(100, 100, 30)';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT LONGLAT_ASQUADINT(100, 100, -1)';
    await expect(runQuery(query)).rejects.toThrow();
});

test('LONGLAT_ASQUADINT should fail if any NULL argument', async () => {
    let query = 'SELECT LONGLAT_ASQUADINT(NULL, 10, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT LONGLAT_ASQUADINT(10, NULL, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT LONGLAT_ASQUADINT(10, 10, NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});