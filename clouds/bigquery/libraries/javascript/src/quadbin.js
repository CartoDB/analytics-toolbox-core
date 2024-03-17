
function polyfillQuery (inputQuery, resolution, mode, outputTable, bqDataset) {
    outputTable = outputTable.replace(/`/g, '');

    const containmentFunction = (mode === 'contains') ? 'ST_CONTAINS' : 'ST_INTERSECTS';
    const cellFunction = (mode === 'center') ? `${bqDataset}.QUADBIN_CENTER` : `${bqDataset}.QUADBIN_BOUNDARY`;

    return `
        CREATE TABLE \`${outputTable}\` CLUSTER BY (quadbin) AS
        WITH __input AS (
            ${inputQuery}
        ),
        __indexed_input AS (
            SELECT *, ROW_NUMBER() OVER () AS __index
            FROM __input
        ),
        __all_parents AS (
            SELECT parent, ST_CONTAINS(i.geom, \`${bqDataset}.QUADBIN_BOUNDARY\`(parent)) AS inside, i.__index
            FROM __indexed_input i, UNNEST(\`${bqDataset}.__QUADBIN_POLYFILL_INIT\`(i.geom, GREATEST(0, ${resolution} - 5))) AS parent
        ),
        __all_cells AS (
            SELECT quadbin, inside, __index
            FROM __all_parents p, UNNEST(\`${bqDataset}.QUADBIN_TOCHILDREN\`(p.parent, ${resolution})) AS quadbin
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
            WHERE ${containmentFunction}(i.geom, \`${cellFunction}\`(quadbin))
        )
        SELECT * EXCEPT (geom, __index)
        FROM __cells
        JOIN __indexed_input
        USING (__index)
    `;
}

export default {
    polyfillQuery
};