const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('QUADKEY conversion should work', async () => {
    const query = `SELECT QUADKEY_FROMQUADINT(
                            QUADINT_FROMZXY(2, 1, 1)) as quadkey1,
                        QUADKEY_FROMQUADINT(
                            QUADINT_FROMZXY(6, 40, 55)) as quadkey2,
                        QUADKEY_FROMQUADINT(
                            QUADINT_FROMZXY(12, 1960, 3612)) as quadkey3,
                        QUADKEY_FROMQUADINT(
                            QUADINT_FROMZXY(18, 131621, 65120)) as quadkey4,
                        QUADKEY_FROMQUADINT(
                            QUADINT_FROMZXY(24, 9123432, 159830174)) as quadkey5,
                        QUADKEY_FROMQUADINT(
                            QUADINT_FROMZXY(29, 389462872, 207468912)) as quadkey6`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].QUADKEY1).toEqual('03');
    expect(rows[0].QUADKEY2).toEqual('321222');
    expect(rows[0].QUADKEY3).toEqual('233110123200');
    expect(rows[0].QUADKEY4).toEqual('102222223002300101');
    expect(rows[0].QUADKEY5).toEqual('300012312213011021123220');
    expect(rows[0].QUADKEY6).toEqual('12311021323123033301303231000');
});

test('Should be able to encode/decode between quadint and quadkey at any level of zoom', async () => {
    const query = `WITH tileContext AS(
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
            ZXY_FROMQUADINT(
                QUADINT_FROMQUADKEY(
                    QUADKEY_FROMQUADINT(
                    QUADINT_FROMZXY(zoom, tileX, tileY)))) AS decodedQuadkey
            FROM tileContext
        )
        WHERE tileX != GET(decodedQuadkey,'x') OR tileY != GET(decodedQuadkey,'y') OR zoom != GET(decodedQuadkey,'z')`;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});

test('QUADKEY_FROMQUADINT should fail with NULL argument', async () => {
    const query = 'SELECT QUADKEY_FROMQUADINT(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});