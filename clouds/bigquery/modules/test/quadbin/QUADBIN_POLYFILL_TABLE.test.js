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
    expect(rows[0].output).toEqual(`CREATE TABLE \`<project>.<dataset>.<output_table>\` CLUSTER BY (quadbin) AS
WITH __input AS (SELECT geom, name, value FROM \`<project>.<dataset>.<table>\`),
__cells AS (SELECT quadbin, i.* FROM __input AS i,
UNNEST(\`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT\`(geom,\`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT_Z\`(geom,12))) AS parent,
UNNEST(\`@@BQ_DATASET@@.QUADBIN_TOCHILDREN\`(parent,12)) AS quadbin)
SELECT * EXCEPT (geom) FROM __cells
WHERE ST_INTERSECTS(geom, \`@@BQ_DATASET@@.QUADBIN_CENTER\`(quadbin));`.replace(/@@BQ_DATASET@@/g, BQ_DATASET));
});
