const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('BBOX integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_QUADKEY) {
            throw "Missing BQ_DATASET_QUADKEY env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });
    
    it ('CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX should work', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX(-45,30,2,10,2,5) as agg1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX(150,-30,16,18,1,5) as agg2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX(170,-150,20,24,1,4) as agg3
        ;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        let expectedArr = [
            { id: 107271, z: 2, x: 0, y: 0 },
            { id: 1723401, z: 4, x: 3, y: 3 },
            { id: 27668491, z: 6, x: 12, y: 13 },
            { id: 442810381, z: 8, x: 48, y: 52 },
            { id: 7087521807, z: 10, x: 192, y: 211 }
        ];
        assert.deepEqual(rows[0].agg1, expectedArr);
        expectedArr = [
            { id: 41336339518805, z: 16, x: 30037, y: 19248 },
            { id: 165345430776502, z: 17, x: 60074, y: 38497 },
            { id: 661381600073047, z: 18, x: 120149, y: 76994 }
        ];
        assert.deepEqual(rows[0].agg2, expectedArr);
        expectedArr = [
            { id: 2645526169139448, z: 20, x: 509724, y: 307979 },
            { id: 10582104154599896, z: 21, x: 1019448, y: 615959 },
            { id: 42328417721967510, z: 22, x: 2038897, y: 1231919 },
            { id: 169313668800038700, z: 23, x: 4077795, y: 2463838 },
            { id: 677254671024492000, z: 24, x: 8155591, y: 4927676 }
          ];
        assert.deepEqual(rows[0].agg3, expectedArr);
    });

    it ('CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX should return [] with NULL latitud/longitud', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX(NULL,10,10,12,1,5) as agg1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CREATE_POINT_AGGREGATION_TILESET_QUADINT_INDEX(10,NULL,10,12,1,5) as agg2;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].agg1,[]);
        assert.deepEqual(rows[0].agg2,[]);
    });
}); /* QUADKEY integration tests */
