const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('HEXRING', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_H3) {
            throw "Missing BQ_DATASET_H3 env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Works as expected with invalid data', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid, 1 as distance UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid, 1 as distance UNION ALL
    SELECT 3 as id, 0x8928308280fffff as hid, -1 as distance UNION ALL

    -- Distance 0
    SELECT 4 as id, 0x8928308280fffff as hid, 0 as distance
)
SELECT
    id,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.HEXRING(hid, distance) as parent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 4);
        assert.deepEqual(rows[0].parent, []);
        assert.deepEqual(rows[1].parent, []);
        assert.deepEqual(rows[2].parent, []);
        assert.deepEqual(rows[3].parent, [0x8928308280fffff]);
    });

    it ('List the ring correctly', async () => {
        const query = `
WITH ids AS
(
    SELECT 0x8928308280fffff as hid
)
SELECT
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.HEXRING(hid, 1) as d1,
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.HEXRING(hid, 2) as d2
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        /* Data comes from h3core.spec.js */
        assert.deepEqual(rows[0].d1.sort(),
            [   0x8928308280bffff,
                0x89283082807ffff,
                0x89283082877ffff,
                0x89283082803ffff,
                0x89283082873ffff,
                0x8928308283bffff
            ].sort());
        assert.deepEqual(rows[0].d2.sort(),
            [   0x89283082813ffff,
                0x89283082817ffff,
                0x8928308281bffff,
                0x89283082863ffff,
                0x89283082823ffff,
                0x8928308287bffff,
                0x89283082833ffff,
                0x8928308282bffff,
                0x89283082857ffff,
                0x892830828abffff,
                0x89283082847ffff,
                0x89283082867ffff
            ].sort());
    });

    it ('Zero distance returns self', async () => {
        const query = `
WITH ids AS
(
    SELECT 608692970266296319 as hid
)
SELECT
    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.HEXRING(hid, 0) AS self_children
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].self_children, [ 608692970266296319 ]);
    });
}); /* HEXRING integration tests */
