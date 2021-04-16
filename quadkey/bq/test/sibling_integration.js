const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('SIBLING integration tests', () => {
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
  
    it ('SIBLING should work at any level of zoom', async () => {
        let query = `WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,29)) AS zoom
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
        rightSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(expectedQuadint,'right') AS rightSibling
            FROM expectedQuadintContext 
        ),
        upSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(rightSibling,'up') AS upSibling
            FROM rightSiblingContext 
        ),
        leftSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(upSibling,'left') AS leftSibling
            FROM upSiblingContext 
        ),
        downSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(leftSibling,'down') AS downSibling
            FROM leftSiblingContext 
        )
        SELECT *
        FROM downSiblingContext
        WHERE downSibling != expectedQuadint`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('SIBLING should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(NULL, 'up');`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(322, NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* QUADKEY integration tests */
