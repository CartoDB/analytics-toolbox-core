const { runQuery } = require('../../../common/test-utils');

const BQ_DATASET = process.env.BQ_DATASET;

test('H3_POLYFILL_TABLE should work', async () => {
    output_table_name = 'h3_polyfill_table_geom_output'
    let query = `DROP TABLE IF EXISTS \`@@BQ_DATASET@@.${output_table_name}\`;
        CALL \`@@BQ_DATASET@@.H3_POLYFILL_TABLE\`(
        'SELECT ST_GEOGFROMTEXT("POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))") as geom',
        9, 'center',
        '@@BQ_DATASET@@.${output_table_name}'
    )`;
    await runQuery(query);

    const rows = await runQuery(`SELECT * FROM \`@@BQ_DATASET@@.${output_table_name}\``);
    expect(rows.length).toEqual(1);
    expect(rows[0].h3).toEqual('89390cb1b4bffff');

    query = `DROP TABLE IF EXISTS \`@@BQ_DATASET@@.${output_table_name}\``;
    await runQuery(query);
});

test('H3_POLYFILL_TABLE should generate the correct query', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.__H3_POLYFILL_QUERY\`(
        'SELECT geom, name, value FROM \`<project>.<dataset>.<table>\`',
        12, 'center',
        '<project>.<dataset>.<output_table>'
    ) AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual(`CREATE TABLE \`<project>.<dataset>.<output_table>\` CLUSTER BY (h3) AS
WITH __input AS (SELECT geom, name, value FROM \`<project>.<dataset>.<table>\`),
__cells AS (SELECT h3, i.* FROM __input AS i,
UNNEST(\`@@BQ_DATASET@@.__H3_POLYFILL_INIT_BBOX\`(geom,\`@@BQ_DATASET@@.__H3_POLYFILL_INIT_Z\`(geom,12))) AS parent,
UNNEST(\`@@BQ_DATASET@@.H3_TOCHILDREN\`(parent,12)) AS h3)
SELECT * EXCEPT (geom) FROM __cells
WHERE ST_INTERSECTS(geom, \`@@BQ_DATASET@@.H3_CENTER\`(h3));`.replace(/@@BQ_DATASET@@/g, BQ_DATASET));
});