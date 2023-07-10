const { runQuery } = require('../../../common/test-utils');

test('QUADBIN_POLYFILL_MODE all modes wrong input', async () => {
    const modes = [
        'intersects', 'contains', 'center'
    ]
    const inputs = [
        // NULL and empty
        "SELECT 0 AS id, NULL as geom, 2 as resolution",
        "SELECT 1 AS id, ST_GEOGFROMTEXT('POLYGON EMPTY') as geom, 2 as resolution",

        // Invalid resolution
        "SELECT 2 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution",
        "SELECT 3 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 16 as resolution",
        "SELECT 4 AS id, ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution"
    ]
    for (mode in modes) {
        for (input in inputs) {
            const query = `
                WITH inputs AS
                (
                    ${input}
                )
                SELECT
                    QUADBIN_POLYFILL_MODE(geom, resolution, '${mode}') AS results
                FROM inputs
                ORDER BY id ASC
            `;
            await expect( runQuery(query) ).rejects.toThrow(Error);
        }
    }
});

test('H3_POLYFILL_MODE polygons multiple modes', async () => {
    const modes = [
        'intersects',
        'contains',
        'center'
    ]
    const inputs = [
        // normal polygons
        {
            geom: "ST_GEOGFROMTEXT('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))')",
            resolution: 14,
            center: 36,
            intersects: 52,
            contains: 24
        },
        {
            geom: "ST_GEOGFROMTEXT('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))')",
            resolution: 7,
            center: 16,
            intersects: 18,
            contains: 4
        },
        {
            geom: "ST_GEOGFROMTEXT('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))')",
            resolution: 7,
            center: 16,
            intersects: 20,
            contains: 6
        },
        // multipolygons
        {
            geom: "ST_GEOGFROMTEXT('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))')",
            resolution: 7,
            center: 32,
            intersects: 38,
            contains: 10
        },
        {
            geom: "ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POLYGON((20 20, 20 30, 30 30, 30 20, 20 20)), POINT(0 10), LINESTRING(0 0, 1 1),MULTIPOLYGON(((-50 -50, -50 -40, -40 -40, -40 -50, -50 -50)), ((50 50, 50 40, 40 40, 40 50, 50 50))))')",
            resolution: 7,
            center: 56,
            intersects: 70,
            contains: 'raise'
        },
        // extreme resolutions
        {
            geom: "ST_GEOGFROMTEXT('POLYGON((0 0, 0 .0001, .0001 .0001, .0001 0, 0 0))')",
            resolution: 26,
            center: 361,
            intersects: 364,
            contains: 289
        },
        {
            geom: "ST_GEOGFROMTEXT('POLYGON((0 0, 0 50, 50 50, 50 0, 0 0))')",
            resolution:0,
            center: 1,
            intersects: 0,
            contains: 0
        }
    ]
    for await (const mode of modes) {
        for await (const input of inputs) {
            const query = `
                SELECT
                ARRAY_SIZE(
                    QUADBIN_POLYFILL_MODE(${input.geom}, ${input.resolution}, '${mode}')
                ) AS id_count
            `;
            if (input[mode] == 'raise') {
                await expect( runQuery(query) ).rejects.toThrow(Error);
            } else {
                const rows = await runQuery(query);
                expect(rows.length).toEqual(1);
                expect(rows.map((r) => r.ID_COUNT)).toEqual([input[mode]]);
            }
        }
    }
});

test('H3_POLYFILL_MODE other geom types', async () => {
    const modes = [
        'intersects',
        'contains',
        'center'
    ]
    const inputs = [
        {
            geom: "ST_GEOGFROMTEXT('POINT(0 0)')",
            resolution: 15,
            center: 0,
            intersects: 1,
            contains: 0
        },
        {
            geom: "ST_GEOGFROMTEXT('MULTIPOINT(0 0, 1 1)')",
            resolution: 15,
            center: 0,
            intersects: 2,
            contains: 0
        },
        {
            geom: "ST_GEOGFROMTEXT('LINESTRING(0 0, 1 1)')",
            resolution: 3,
            center: 0,
            intersects: 2,
            contains: 0
        },
        {
            geom: "ST_GEOGFROMTEXT('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))')",
            resolution: 3,
            center: 0,
            intersects: 2,
            contains: 0
        },
        // a geometry collection containing only not supported types)
        {
            geom: "ST_GEOGFROMTEXT('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))')",
            resolution: 1,
            center: 0,
            intersects: 4,
            contains: 'raise'
        },
        // Polygon larger than 180 degrees
        {
            geom: `TO_GEOGRAPHY('{"type":"Polygon","coordinates":[[[-161.44993041898587,-3.77971025880735],[129.99811811657568,-3.77971025880735],[129.99811811657568,63.46915831771922],[-161.44993041898587,63.46915831771922],[-161.44993041898587,-3.77971025880735]]]}')`,
            resolution: 3,
            center: 2,
            intersects: 11,
            contains: 1
        }
    ]
    for await (const mode of modes) {
        for await (const input of inputs) {
            const query = `
                SELECT
                ARRAY_SIZE(
                    QUADBIN_POLYFILL_MODE(${input.geom}, ${input.resolution}, '${mode}')
                ) AS id_count
            `;
            if (input[mode] == 'raise') {
                console.log("rise")
                await expect( runQuery(query) ).rejects.toThrow(Error);
            } else {
                const rows = await runQuery(query);
                console.log(mode, rows)
                expect(rows.length).toEqual(1);
                expect(rows.map((r) => r.ID_COUNT)).toEqual([input[mode]]);
            }
        }
    }
});
