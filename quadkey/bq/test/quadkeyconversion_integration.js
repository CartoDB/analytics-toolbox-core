const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('QUADKEY conversions integration tests', () => {
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

    it ('QUADKEY conversion should work', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(2, 1, 1)) as quadkey1,
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(6, 40, 55)) as quadkey2,
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(12, 1960, 3612)) as quadkey3,
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(18, 131621, 65120)) as quadkey4,
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(24, 9123432, 159830174)) as quadkey5,
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(29, 389462872, 207468912)) as quadkey6`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].quadkey1, "03");
        assert.equal(rows[0].quadkey2, "321222");
        assert.equal(rows[0].quadkey3, "233110123200");
        assert.equal(rows[0].quadkey4, "102222223002300101");
        assert.equal(rows[0].quadkey5, "300012312213011021123220");
        assert.equal(rows[0].quadkey6, "12311021323123033301303231000");
    });

    it ('Should be able to encode/decode between quadint and quadkey at any level of zoom', async () => {
        let query = `WITH tileContext AS
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
        )
        SELECT *
        FROM 
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ZXY_FROMQUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMQUADKEY(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY)))) AS decodedQuadkey
            FROM tileContext
        )
        WHERE tileX != decodedQuadkey.x OR tileY != decodedQuadkey.y OR zoom != decodedQuadkey.z`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('QUADKEY_FROMQUADINT should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROMQUADINT(NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* QUADKEY integration tests */
