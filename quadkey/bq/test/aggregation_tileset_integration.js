const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('LONGLAT_ASQUADINTLIST_RESOLUTION integration tests', () => {
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
    
    it ('LONGLAT_ASQUADINTLIST_RESOLUTION should work', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINTLIST_RESOLUTION(-45,30,2,10,2,5) as agg1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINTLIST_RESOLUTION(150,-30,16,18,1,5) as agg2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINTLIST_RESOLUTION(170,-80,20,24,1,4) as agg3
        ;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        let expectedArr = [
            { id: 214535, z: 2, x: 1, y: 1 },
            { id: 3463177, z: 4, x: 6, y: 6 },
            { id: 55336971, z: 6, x: 24, y: 26 },
            { id: 885882893, z: 8, x: 96, y: 105 },
            { id: 14176092175, z: 10, x: 384, y: 422 }
        ];
        assert.deepEqual(rows[0].agg1, expectedArr);
        expectedArr = [
            { id: 82672746146485, z: 16, x: 60074, y: 38497 },
            { id: 330690861552982, z: 17, x: 120149, y: 76994 },
            { id: 1322763200146103, z: 18, x: 240298, y: 153989 }
        ];
        assert.deepEqual(rows[0].agg2, expectedArr);
        expectedArr = [
            { id: 7996056564167128, z: 20, x: 1019448, y: 930863 },
            { id: 31984226286494616, z: 21, x: 2038897, y: 1861726 },
            { id: 127936905205630750, z: 22, x: 4077795, y: 3723453 },
            { id: 511747616646860350, z: 23, x: 8155591, y: 7446907 },
            { id: 2046990466826050600, z: 24, x: 16311182, y: 14893815 }
          ];
        assert.deepEqual(rows[0].agg3, expectedArr);
    });

    it ('LONGLAT_ASQUADINTLIST_RESOLUTION should return [] with NULL latitud/longitud', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINTLIST_RESOLUTION(NULL,10,10,12,1,5) as agg1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINTLIST_RESOLUTION(10,NULL,10,12,1,5) as agg2;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].agg1,[]);
        assert.deepEqual(rows[0].agg2,[]);
    });
}); /* QUADKEY integration tests */
