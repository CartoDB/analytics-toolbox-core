const { runQuery, deleteTable } = require('../../../common/test-utils');

test('H3_POLYFILL_TABLE should work', async () => {
    await deleteTable('@@SF_SCHEMA@@.polyfill_test_output_table');

    let query = `CALL @@SF_SCHEMA@@.H3_POLYFILL_TABLE(
                    'SELECT TO_GEOGRAPHY(
                        ''POLYGON ((-3.71219873428345 40.413365349070865,
                                    -3.7144088745117 40.40965661286395,
                                    -3.70659828186035 40.409525904775634,
                                    -3.71219873428345 40.413365349070865
                                ))''
                        ) AS geom',
                    9, 'intersects',
                    '@@SF_SCHEMA@@.polyfill_test_output_table'
                  );`;
    await runQuery(query);

    query = 'SELECT * FROM @@SF_SCHEMA@@.polyfill_test_output_table`;';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(6);

    await deleteTable('@@SF_SCHEMA@@.polyfill_test_output_table');
});
