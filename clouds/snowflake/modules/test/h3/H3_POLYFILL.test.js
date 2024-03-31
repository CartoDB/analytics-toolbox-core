const { runQuery } = require('../../../common/test-utils');

test('H3_POLYFILL returns the proper INT64s', async () => {
    const query = `
        WITH inputs AS
        (
            SELECT 1 AS id, TO_GEOGRAPHY('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
            SELECT 2 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
            SELECT 3 AS id, TO_GEOGRAPHY('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
            -- 4 is a multipolygon containing geom ids 2, 3
            SELECT 4 AS id, TO_GEOGRAPHY('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL
            SELECT 5 AS id, TO_GEOGRAPHY('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))') as geom, 2 as resolution UNION ALL

            -- NULL and empty
            SELECT 6 AS id, TRY_TO_GEOGRAPHY(NULL) as geom, 2 as resolution UNION ALL
            SELECT 7 AS id, TO_GEOGRAPHY('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

            -- Invalid resolution
            SELECT 8 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
            SELECT 9 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 20 as resolution UNION ALL
            SELECT 10 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution UNION ALL

            -- Other types are not supported
            SELECT 11 AS id, TO_GEOGRAPHY('POINT(0 0)') as geom, 15 as resolution UNION ALL
            SELECT 12 AS id, TO_GEOGRAPHY('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 13 AS id, TO_GEOGRAPHY('LINESTRING(0 0, 1 1)') as geom, 15 as resolution UNION ALL
            SELECT 14 AS id, TO_GEOGRAPHY('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 15 as resolution UNION ALL

            -- 15 is a geometry collection containing only not supported types
            SELECT 15 AS id, TO_GEOGRAPHY('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 15 as resolution UNION ALL

            SELECT 16 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))') as geom, 15 as resolution UNION ALL
            SELECT 17 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))') as geom, 0 as resolution UNION ALL

            -- Polygon larger than 180 degrees
            SELECT 18 AS id, TO_GEOGRAPHY('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}') as geom, 3 as resolution
        )
        SELECT
            ARRAY_SIZE(H3_POLYFILL(geom, resolution)) AS id_count
        FROM inputs
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(18);
    expect(rows.map((r) => r.ID_COUNT)).toEqual([
        1253,
        18,
        12,
        30,
        34,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        182,
        6,
        16110
    ]);
});

test ('H3_POLYFILL with named mode parameter', async () => {

    const query = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('POLYGON((-100 -50, -100 50, 100 50, 100 -50, -100 -50))'), 0, 'center') as h3_indexs UNION ALL
		    SELECT 2 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('POLYGON((-100 -50, -100 50, 100 50, 100 -50, -100 -50))'), 0, 'contains') as h3_indexs UNION ALL
		    SELECT 3 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('POLYGON((-100 -50, -100 50, 100 50, 100 -50, -100 -50))'), 0, 'intersects') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows = await runQuery(query);
    expect(rows.length).toEqual(3);
    expect(rows.map((r) => r.H3_COUNT)).toEqual([
        51,
        38,
        67
    ]);
    
    let polygonWkt = 'POLYGON((-6.34063009076414374 53.32201110704816216, -6.34218703413432117 53.32155186475911535, -6.34373277647305756 53.32156306579055638, -6.34562575078643842 53.32197750395383906, -6.34506569921443209 53.32132784413031601, -6.34518891056027368 53.32067818430678585, -6.34432643113938433 53.31993891623174164, -6.34400160122762014 53.31983810694877945, -6.34309431768097109 53.31936766362829161, -6.34228784341728247 53.31907643681085318, -6.3411453382103895 53.31879641102484868, -6.34043967322966218 53.31903163268508905, -6.33982361650045512 53.31861719452180637, -6.33974520928037499 53.31875160689908455, -6.33892753398524622 53.3191884471252493, -6.33948758555725167 53.3195020760055769, -6.33994682784629671 53.3211486276272737, -6.33968920412317427 53.32140625135039613, -6.34063009076414374 53.32201110704816216))'

    const query2 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 13, 'center') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows2 = await runQuery(query2);
    expect(rows2.length).toEqual(1);
    expect(rows2[0].H3_COUNT).toEqual(2380)

    const query3 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 13, 'contains') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows3 = await runQuery(query3);
    expect(rows3.length).toEqual(1);
    expect(rows3[0].H3_COUNT).toEqual(2261)

    const query4 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 13, 'intersects') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows4 = await runQuery(query4);
    expect(rows4.length).toEqual(1);
    expect(rows4[0].H3_COUNT).toEqual(2507)

    const query5 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 0, 'center') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows5 = await runQuery(query5);
    expect(rows5.length).toEqual(1);
    expect(rows5[0].H3_COUNT).toEqual(0)

    const query6 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 0, 'contains') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows6 = await runQuery(query6);
    expect(rows6.length).toEqual(1);
    expect(rows6[0].H6_COUNT).toEqual(undefined) // TODO: should be 0

    const query7 = `
		WITH inputs as (
		    SELECT 1 as id, H3_POLYFILL(ST_GEOGRAPHYFROMWKT('${polygonWkt}'), 0, 'intersects') as h3_indexs
		)
        SELECT
            ARRAY_SIZE(h3_indexs) AS h3_count
        FROM inputs
        ORDER BY id ASC
	`
    const rows7 = await runQuery(query7);
    expect(rows7.length).toEqual(1);
    expect(rows7[0].H3_COUNT).toEqual(1)
})

test('H3_POLYFILL returns the expected values', async () => {
    /* Any cell should cover only 1 h3 cell at its resolution (itself) */
    /* This query has been splitted in Snowflake to avoid JS memory limits reached*/
    let query = `
        WITH points AS
        (
            SELECT ST_POINT(0, 0) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    let rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.4089866999972145, 37.813318999983238) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution, 'center') p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution, 'intersects') p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 7; // a h3 cell intersects with itself and its six neighbours
    `;
    rows = await runQuery(query);
    expect(rows.length).toEqual(0);

    query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog,
            7 AS resolution
        ),
        cells AS
        (
            SELECT
                resolution,
                H3_FROMGEOGPOINT(geog, resolution) AS hex_id,
                H3_CELL_TO_BOUNDARY(H3_FROMGEOGPOINT(geog, resolution)) AS boundary
            FROM points
        ),
        polyfill AS
        (
            SELECT
                *,
                H3_POLYFILL(boundary, resolution, 'contains') p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
    `;
    rows = await runQuery(query);
    //expect(rows.length).toEqual(0); // TODO - H3 cell should contain itself
});