const { runQuery } = require('../../../common/test-utils');

test('S2_TOUINT64REPR should work', async () => {
    const query = `
    SELECT \`@@BQ_DATASET@@.S2_TOUINT64REPR\`(key) as id
    FROM UNNEST([-8520148382826627072, -2520148382826627072, 2520148382826627072, 8520148382826627072]) as key
    order by id
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows[0].id.toString()).toEqual('15926595690882924544');
    expect(rows[1].id.toString()).toEqual('2520148382826627072');
    expect(rows[2].id.toString()).toEqual('8520148382826627072');
    expect(rows[3].id.toString()).toEqual('9926595690882924544');
});