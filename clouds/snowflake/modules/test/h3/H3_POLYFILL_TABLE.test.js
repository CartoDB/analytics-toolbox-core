const { runQuery } = require('../../../common/test-utils');

const SF_SCHEMA = process.env.SF_SCHEMA;

test('H3_POLYFILL_TABLE should generate the correct query', async () => {
    const query = `SELECT @@SF_SCHEMA@@._H3_POLYFILL_QUERY(
        'SELECT geom, name, value FROM <project>.<dataset>.<table>',
        12, 'center',
        '<project>.<dataset>.<output_table>'
    ) AS output`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual(`
        CREATE OR REPLACE TABLE <project>.<dataset>.<output_table> CLUSTER BY (h3) AS
        WITH __input AS (SELECT geom, name, value FROM <project>.<dataset>.<table>),
        __cells AS (
            SELECT CAST(children.value AS STRING) AS h3, i.*
            FROM __input AS i,
                TABLE(FLATTEN(@@SF_SCHEMA@@._H3_POLYFILL_INIT(geom, 8))) AS parent,
                TABLE(FLATTEN(@@SF_SCHEMA@@.H3_TOCHILDREN(CAST(parent.value AS STRING), 12))) AS children
        )
        SELECT * EXCLUDE(geom)
        FROM __cells
        WHERE ST_INTERSECTS(geom, @@SF_SCHEMA@@.H3_CENTER(h3))
    `.replace(/@@SF_SCHEMA@@/g, SF_SCHEMA));
});