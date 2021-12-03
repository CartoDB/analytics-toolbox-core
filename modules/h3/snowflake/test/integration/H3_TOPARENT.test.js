const { runQuery } = require('../../../../../common/snowflake/test-utils');

test('H3_TOPARENT works as expected with invalid data', async () => {
    const query = `
        WITH ids AS
        (
            -- Invalid parameters
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, '0xff283473fffffff' as hid
        )
        SELECT
            id,
            H3_TOPARENT(hid, 1) as parent
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].PARENT).toEqual(null);
    expect(rows[0].PARENT).toEqual(null);
});

test('Equivalent to previous resolution level', async () => {
    /* From h3-js tests:
        // NB: This test will not work with every hexagon, it has to be a location
        // that does not fall in the margin of error between the 7 children and
        // the parent's true boundaries at every resolution
     */
    let query = `
        WITH ids AS
        (
            SELECT
                ST_POINT(-122.409290778685, 37.81331899988944) as point,
                seq4() + 1 AS resolution
            FROM TABLE(generator(rowcount => 5))
        )
        SELECT
            *
        FROM ids
        WHERE
            H3_FROMGEOGPOINT(point, resolution) != H3_TOPARENT(H3_FROMGEOGPOINT(point, resolution + 1), resolution) OR
            H3_FROMGEOGPOINT(point, resolution) != H3_TOPARENT(H3_FROMGEOGPOINT(point, resolution + 2), resolution)
    `;

    let rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH ids AS
        (
            SELECT
                ST_POINT(-122.409290778685, 37.81331899988944) as point,
                seq4() + 6 AS resolution
            FROM TABLE(generator(rowcount => 5))
        )
        SELECT
            *
        FROM ids
        WHERE
            H3_FROMGEOGPOINT(point, resolution) != H3_TOPARENT(H3_FROMGEOGPOINT(point, resolution + 1), resolution) OR
            H3_FROMGEOGPOINT(point, resolution) != H3_TOPARENT(H3_FROMGEOGPOINT(point, resolution + 2), resolution)
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});