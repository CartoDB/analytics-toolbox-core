const { runQuery } = require('../../../common/test-utils');

test('QUADINT_TOCHILDREN should work at any level of zoom', async () => {
    const query = `WITH tileContext AS(
        WITH z AS
        (
            SELECT seq4() AS z
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
            CAST((POW(2,zoom)-1)*x/10 AS INT) AS tileX,
            CAST((POW(2,zoom)-1)*y/10 AS INT) AS tileY
            FROM z,x,y
            GROUP BY zoom,tileX,tileY
        ),
        expectedQuadintContext AS
        (
            SELECT *,
            QUADINT_FROMZXY(zoom, tileX, tileY) AS expectedQuadint
            FROM tileContext
        ),
        childrenContext AS
        (
            SELECT *,
            QUADINT_TOCHILDREN(expectedQuadint, zoom + 1) AS children
            FROM expectedQuadintContext 
        )
        SELECT *
        FROM 
        (
            SELECT expectedQuadint,
            QUADINT_TOPARENT(child.value, zoom) AS currentQuadint
            FROM childrenContext, LATERAL FLATTEN(input => children) AS child
        )
        WHERE currentQuadint != expectedQuadint`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('QUADINT_TOCHILDREN should reject quadints at zoom 29', async () => {
    const query = 'SELECT QUADINT_TOCHILDREN(4611686027017322525,30)';
    await expect(runQuery(query)).rejects.toThrow();
});

test('QUADINT_TOCHILDREN should fail with NULL arguments', async () => {
    let query = 'SELECT QUADINT_TOCHILDREN(NULL, 1);';
    await expect(runQuery(query)).rejects.toThrow();

    query = 'SELECT QUADINT_TOCHILDREN(322, NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});