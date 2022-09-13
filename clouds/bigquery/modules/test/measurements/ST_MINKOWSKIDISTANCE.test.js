const { runQuery } = require('../../../common/test-utils');

test('ST_MINKOWSKIDISTANCE should work', async () => {
    const query = `
        SELECT \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`([ST_GEOGPOINT(0,0),ST_GEOGPOINT(1,0)], 2) as minkowskidistance1,
               \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`([ST_GEOGPOINT(0,0),ST_GEOGPOINT(100,0)], 2) as minkowskidistance2,
               \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`([ST_GEOGPOINT(0,0),ST_GEOGPOINT(10,10)], 2) as minkowskidistance3,
               \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`([ST_GEOGPOINT(0,0),ST_GEOGPOINT(10,10)], 1) as minkowskidistance4,
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].minkowskidistance1).toEqual(['0,1','1,0']);
    expect(rows[0].minkowskidistance2).toEqual(['0,0.01','0.01,0']);
    expect(rows[0].minkowskidistance3).toEqual(['0,0.07071067811865475','0.07071067811865475,0']);
    expect(rows[0].minkowskidistance4).toEqual(['0,0.05','0.05,0']);
});

test('ST_MINKOWSKIDISTANCE should return NULL if any NULL mandatory argument', async () => {
    const query = `
        SELECT \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`(NULL, 2) as minkowskidistance1
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].minkowskidistance1).toEqual([]);
});

test('ST_MINKOWSKIDISTANCE default values should work', async () => {
    const query = `
        SELECT \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`([ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167)], 2) as defaultValue,
               \`@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE\`([ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-5.70325 ,40.4167)], NULL) as nullParam
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam).toEqual(rows[0].defaultValue);
});