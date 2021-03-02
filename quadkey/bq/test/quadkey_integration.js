const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('QUADKEY integration tests', () => {
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
  
    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('Should be able to encode/decode quadints at different zooms', async () => {
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
                    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY)) as decodedQuadkey
                FROM tileContext
            )
            WHERE tileX != decodedQuadkey.x OR tileY != decodedQuadkey.y OR zoom != decodedQuadkey.z`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
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
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY)))) as decodedQuadkey
            FROM tileContext
        )
        WHERE tileX != decodedQuadkey.x OR tileY != decodedQuadkey.y OR zoom != decodedQuadkey.z`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('Parent should work at any level of zoom', async () => {
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
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom - 1) as expectedParent,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.PARENT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom)) as parent
            FROM zoomContext
        )
        WHERE parent != expectedParent`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('Children should work at any level of zoom', async () => {
        let query = `WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,28)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(-90,90,15)) lat,
                UNNEST(GENERATE_ARRAY(-180,180,15)) long
        ),
        expectedQuadintContext AS
        (
            SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom) as expectedQuadint,
            FROM zoomContext
        ),
        childrenContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CHILDREN(expectedQuadint) as children
            FROM expectedQuadintContext 
        )
        SELECT *
        FROM 
        (
            SELECT expectedQuadint,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.PARENT(child) as currentQuadint
            FROM childrenContext, UNNEST(children) as child
        )
        WHERE currentQuadint != expectedQuadint`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('Sibling should work at any level of zoom', async () => {
        let query = `WITH zoomContext AS
        (
            WITH zoomValues AS
            (
                SELECT zoom FROM UNNEST (GENERATE_ARRAY(0,29)) AS zoom
            )
            SELECT *
            FROM
                zoomValues,
                UNNEST(GENERATE_ARRAY(-89,89,15)) lat,
                UNNEST(GENERATE_ARRAY(-179,179,15)) long
        ),
        expectedQuadintContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom) as expectedQuadint,
            FROM zoomContext
        ),
        rightSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(expectedQuadint,'right') as rightSibling
            FROM expectedQuadintContext 
        ),
        upSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(rightSibling,'up') as upSibling
            FROM rightSiblingContext 
        ),
        leftSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(upSibling,'left') as leftSibling
            FROM upSiblingContext 
        ),
        downSiblingContext AS
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.SIBLING(leftSibling,'down') as downSibling
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

    
}); /* QUADKEY integration tests */
