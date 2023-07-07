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

