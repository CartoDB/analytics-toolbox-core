const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('CHILDREN integration tests', () => {
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

    it ('CHILDREN should work at any level of zoom', async () => {
        let query = `WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,28)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(0,CAST(pow(2, zoom) - 1 AS INT64),COALESCE(NULLIF(CAST(pow(2, zoom)*0.02 AS INT64),0),1))) tileX,
                UNNEST(GENERATE_ARRAY(0,CAST(pow(2, zoom) - 1 AS INT64),COALESCE(NULLIF(CAST(pow(2, zoom)*0.02 AS INT64),0),1))) tileY
        ),
        expectedQuadintContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY) AS expectedQuadint,
            FROM zoomContext
        ),
        childrenContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CHILDREN(expectedQuadint) AS children
            FROM expectedQuadintContext 
        )
        SELECT *
        FROM 
        (
            SELECT expectedQuadint,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(child, zoom) AS currentQuadint
            FROM childrenContext, UNNEST(children) AS child
        )
        WHERE currentQuadint != expectedQuadint`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('CHILDREN should reject quadints at zoom 29', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CHILDREN(4611686027017322525)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

    it ('CHILDREN should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CHILDREN(NULL);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
    });
}); /* QUADKEY integration tests */
