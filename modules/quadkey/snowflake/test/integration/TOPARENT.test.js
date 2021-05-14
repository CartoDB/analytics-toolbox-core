const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('TOPARENT should work at any level of zoom', async () => {
    let query = `WITH zoomContext AS(
            WITH z AS
            (
                SELECT seq4()+1 AS z
                FROM TABLE(generator(rowcount => 29))
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
            SELECT *,
            @@SF_PREFIX@@quadkey.ST_ASQUADINT(ST_POINT(long, lat), zoom - 1) AS expectedParent,
            @@SF_PREFIX@@quadkey.TOPARENT(
                @@SF_PREFIX@@quadkey.ST_ASQUADINT(ST_POINT(long, lat), zoom),zoom - 1) AS parent
            FROM zoomContext
        )
        WHERE parent != expectedParent`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('TOPARENT should reject quadints at zoom 0', async () => {
    let query = 'SELECT @@SF_PREFIX@@quadkey.TOPARENT(0,0)';
    await expect(runQuery(query)).rejects.toThrow();
});

test('TOPARENT should fail with NULL argument', async () => {
    let query = 'SELECT @@SF_PREFIX@@quadkey.TOPARENT(NULL, 10);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT @@SF_PREFIX@@quadkey.TOPARENT(322, NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});
