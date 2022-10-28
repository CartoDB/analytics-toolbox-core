const { runQuery } = require('../../../common/test-utils');

test('Same resolution lists self', async () => {
    const query = `
        SELECT ARRAY_AGG(child) AS self_children
        FROM UNNEST(\`@@BQ_DATASET@@.S2_TOCHILDREN\`(6432928348669739008, 12)) child
        WHERE child not in (SELECT * FROM UNNEST([6432928554828169216, 6432928417389215744, 6432928279950262272, 6432928142511308800]))
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].self_children).toEqual([]);
});
