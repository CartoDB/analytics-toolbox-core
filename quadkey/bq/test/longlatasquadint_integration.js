const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('LONGLAT_ASQUADINT integration tests', () => {
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

    it ('LONGLAT_ASQUADINT should not fail at any level of zoom', async () => {
        let query = `WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(1,29)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(-85,85,15)) lat,
                UNNEST(GENERATE_ARRAY(-179,179,15)) long
        )
        SELECT *
        FROM 
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINT(long, lat, zoom)
            FROM zoomContext
        )`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

    it ('Should fail to encode quadints at zooms bigger than 29 or smaller than 0', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINT(100, 100, 30)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINT(100, 100, -1)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });


    it ('LONGLAT_ASQUADINT should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINT(NULL, 10, 10);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINT(10, NULL, 10);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.LONGLAT_ASQUADINT(10, 10, NULL);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
    });
}); /* QUADKEY integration tests */
