const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_S2 = process.env.BQ_DATASET_S2;

describe('GEOJSONBOUNDARY_FROMID integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_S2) {
            throw "Missing BQ_DATASET_S2 env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it('Boundary functions should work', async() => {
        const level = 18;
        const latitude = -14;
        const longitude = 125;
        const bounds = {
            "type": "Polygon",
            "coordinates": [[
                [124.99991607494462, -14.000016145055083],
                [124.99991607494462, -13.99970528488021],
                [125.0002604046465, -13.999648690569117],
                [125.0002604046465, -13.999959549588995],
                [124.99991607494462, -14.000016145055083]
            ]]
        };

        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.GEOJSONBOUNDARY_FROMID(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.LONGLAT_ASID(${longitude},${latitude},${level})) as boundary;`;
        
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        let resultBoundary = JSON.parse(rows[0].boundary);
        assert.equal(rows.length, 1);
        assert.deepEqual(bounds, resultBoundary);
    });

    it ('GEOJSONBOUNDARY_FROMID should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.GEOJSONBOUNDARY_FROMID(NULL);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
    });
}); /* S2 integration tests */
