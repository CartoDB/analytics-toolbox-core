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
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.VERSION() AS versioncol;`;
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
                    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY)) AS decodedQuadkey
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
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY)))) AS decodedQuadkey
            FROM tileContext
        )
        WHERE tileX != decodedQuadkey.x OR tileY != decodedQuadkey.y OR zoom != decodedQuadkey.z`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
    });

    it ('PARENT should work at any level of zoom', async () => {
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
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.PARENT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(long, lat), zoom)) AS parent
            FROM zoomContext
        )
        WHERE parent != expectedParent`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
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
            SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMZXY(zoom, tileX, tileY) AS expectedQuadint,
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
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.PARENT(child) AS currentQuadint
            FROM childrenContext, UNNEST(children) AS child
        )
        WHERE currentQuadint != expectedQuadint`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 0);
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

    it ('KRING should work', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(162) as kring1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12070922) as kring2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(791040491538) as kring3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.KRING(12960460429066265) as kring4`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0]['kring1'],[130, 2, 258, 194, 66, 322, 34, 290, 162]);
        assert.deepEqual(rows[0]['kring2'],[12070890, 12038122, 12103658, 12070954, 12038186, 12103722, 12038154, 12103690, 12070922]);
        assert.deepEqual(rows[0]['kring3'],[791040491506, 791032102898, 791048880114, 791040491570, 791032102962, 791048880178, 791032102930, 791048880146, 791040491538]);
        assert.deepEqual(rows[0]['kring4'],[12960460429066232, 12960459355324408, 12960461502808056, 12960460429066296, 12960459355324472, 12960461502808120, 12960459355324440, 12960461502808088, 12960460429066264]);
    });

    it ('BBOX should work', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(162) as bbox1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(12070922) as bbox2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(791040491538) as bbox3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.BBOX(12960460429066265) as bbox4`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0]['bbox1'],[-90, 0, 0, 66.51326044311185]);
        assert.deepEqual(rows[0]['bbox2'],[-45.00000000000001, 44.84029065139799, -44.648437500000014, 45.08903556483102]);
        assert.deepEqual(rows[0]['bbox3'],[-45.00000000000001, 44.99976701918129, -44.99862670898438, 45.00073807829065]);
        assert.deepEqual(rows[0]['bbox4'],[-45.00000000000001, 44.9999946126367, -44.99998927116395, 45.00000219906963]);
    });
}); /* QUADKEY integration tests */
