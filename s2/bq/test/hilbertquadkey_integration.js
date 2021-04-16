const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_S2 = process.env.BQ_DATASET_S2;

describe('HILBERTQUADKEY conversion integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
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

    it ('KEY / ID conversions should work', async () => {
        let query = `
        WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(1,29)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(-89,89,15)) lat,
                UNNEST(GENERATE_ARRAY(-179,179,15)) long
        ),
        idContext AS (
            SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.LONGLAT_ASID(long, lat, zoom) AS expectedID,
            FROM zoomContext
        )
        SELECT *
        FROM 
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(expectedID)) AS decodedID
            FROM idContext
        )
        WHERE decodedID != expectedID`;

        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it('Quadkey to S2 id static conversions', async() => {
        let query = `SELECT CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY('4/12') AS STRING) AS id1,
        CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY('2/02300033') AS STRING) AS id2,
        CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY('3/03131200023201') AS STRING) AS id3,
        CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY('5/0001221313222222120') AS STRING) AS id4,
        CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY('2/0221200002312111222332101') AS STRING) AS id5,
        CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY('5/1331022022103232320303230131') AS STRING) AS id6`;

        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].id1,'-8286623314361712640');
        assert.equal(rows[0].id2,'5008548143403368448');
        assert.equal(rows[0].id3,'7416309021449125888');
        assert.equal(rows[0].id4,'-6902629179221606400');
        assert.equal(rows[0].id5,'4985491052606295040');
        assert.equal(rows[0].id6,'-5790199077674720336');
    });

    it('S2 id to quadkey static conversions', async() => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(-5062045981164437504) AS key1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(5159154848129613824) AS key2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(3776858106818985984) AS key3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(-6531506317872332800) AS key4,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(7380675754284404736) AS key5,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(1996857078240356732) AS key6`;

        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].key1,'5/303');
        assert.equal(rows[0].key2,'2/033030');
        assert.equal(rows[0].key3,'1/220311003003');
        assert.equal(rows[0].key4,'5/022231231230313331');
        assert.equal(rows[0].key5,'3/030312231223330330032232');
        assert.equal(rows[0].key6,'0/31312302011313121331323110233');
    });

    it ('HILBERTQUADKEY conversions should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMHILBERTQUADKEY(NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.HILBERTQUADKEY_FROMID(NULL);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* S2 integration tests */
