const { runQuery } = require('../../../common/test-utils');

const BQ_DATASET = process.env.BQ_DATASET;

test('QUADBIN_POLYFILL_TABLE should generate the correct query', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.__QUADBIN_POLYFILL_QUERY\`(
        'SELECT geom, name, value FROM \`<project>.<dataset>.<table>\`',
        12, 'center',
        '<project>.<dataset>.<output_table>'
    ) AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(`
        CREATE TABLE \`<project>.<dataset>.<output_table>\` CLUSTER BY (quadbin) AS
        WITH __input AS (
            SELECT geom, name, value FROM \`<project>.<dataset>.<table>\`
        ),
        __indexed_input AS (
            SELECT *, ROW_NUMBER() OVER () AS __index
            FROM __input
        ),
        __all_parents AS (
            SELECT parent, ST_CONTAINS(i.geom, \`@@BQ_DATASET@@.QUADBIN_BOUNDARY\`(parent)) AS inside, i.__index
            FROM __indexed_input i, UNNEST(\`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT\`(i.geom, GREATEST(0, 12 - 5))) AS parent
        ),
        __all_cells AS (
            SELECT quadbin, inside, __index
            FROM __all_parents p, UNNEST(\`@@BQ_DATASET@@.QUADBIN_TOCHILDREN\`(p.parent, 12)) AS quadbin
        ),
        __cells_inside AS (
            SELECT quadbin, __index
            FROM __all_cells
            WHERE inside
        ),
        __cells_border AS (
            SELECT quadbin, __index
            FROM __all_cells
            WHERE NOT inside
        ),
        __cells AS (
            SELECT quadbin, __index
            FROM __cells_inside
            UNION ALL
            SELECT quadbin, __index
            FROM __cells_border
            JOIN __indexed_input i
            USING (__index)
            WHERE ST_INTERSECTS(i.geom, \`@@BQ_DATASET@@.QUADBIN_CENTER\`(quadbin))
        )
        SELECT * EXCEPT (geom, __index)
        FROM __cells
        JOIN __indexed_input
        USING (__index)
    `.replace(/@@BQ_DATASET@@/g, BQ_DATASET));
});