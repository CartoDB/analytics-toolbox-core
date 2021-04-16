const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('TOPARENT integration tests', () => {
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

    it ('TOPARENT should work at any level of zoom', async () => {
        let query = `WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(1,29)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(-90,90,15)) lat,
                UNNEST(GENERATE_ARRAY(-180,180,15)) long
        )
        SELECT *
        FROM 
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom - 1) AS expectedParent,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom),zoom - 1) AS parent
            FROM zoomContext
        )
        WHERE parent != expectedParent`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('TOPARENT should reject quadints with lower level of zoom than the passed resolution', async () => {
        let query = `-- Passing zoom 3 quadint
        SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(291,4)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        query = `-- Passing zoom 10 quadint
        SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(3280010,11)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        query = `-- Passing zoom 14 quadint
        SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(52432014,15)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

    it ('TOPARENT should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(NULL, 10);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.TOPARENT(322, NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* QUADKEY integration tests */
