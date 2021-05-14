const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('Should be able to encode/decode quadints at different zooms', async () => {
    let query = `WITH tileContext AS(
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
            CAST((POW(2,zoom)-1)*x/10 AS INT) AS tileX,
            CAST((POW(2,zoom)-1)*y/10 AS INT) AS tileY
            FROM z,x,y
            GROUP BY zoom,tileX,tileY
        )
        SELECT *
        FROM 
        (
            SELECT *,
            @@SF_PREFIX@@quadkey.ZXY_FROMQUADINT(
                @@SF_PREFIX@@quadkey.QUADINT_FROMZXY(zoom, tileX, tileY)) AS decodedQuadkey
            FROM tileContext
        )
        WHERE tileX != GET(decodedQuadkey,'x') OR tileY != GET(decodedQuadkey,'y') OR zoom != GET(decodedQuadkey,'z')`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});
