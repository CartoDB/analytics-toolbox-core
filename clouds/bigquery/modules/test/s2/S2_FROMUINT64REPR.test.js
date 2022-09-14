const { runQuery } = require('../../../common/test-utils');

test('S2_FROMUINT64REPR should work', async () => {
    const query = `
    SELECT CAST(\`@@BQ_DATASET@@.S2_FROMUINT64REPR\`(key) AS STRING) as id
    FROM UNNEST(["15926595690882924544", "2520148382826627072", "8520148382826627072", "9926595690882924544"]) as key
    order by \`@@BQ_DATASET@@.S2_FROMUINT64REPR\`(key)
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(4);
    expect(rows[0].id.toString()).toEqual('-8520148382826627072');
    expect(rows[1].id.toString()).toEqual('-2520148382826627072');
    expect(rows[2].id.toString()).toEqual('2520148382826627072');
    expect(rows[3].id.toString()).toEqual('8520148382826627072');
});