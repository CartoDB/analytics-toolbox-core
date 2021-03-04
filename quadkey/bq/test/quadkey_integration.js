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

    it ('Should fail to encode quadints at zooms bigger than 29 or smaller than 0', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMLONGLAT(100, 100, 30)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMLONGLAT(100, 100, -1)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
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

    it ('Should reject converting from quadkey for zooms bigger than 29', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMQUADKEY('122221112203312001332221110001')`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

    it ('QUADINT_FROMLONGLAT should not fail at any level of zoom', async () => {
        let query = `WITH zoomContext AS
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
        )
        SELECT *
        FROM 
        (
            SELECT *,
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROMLONGLAT(long, lat, zoom)
            FROM zoomContext
        )`;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
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
                UNNEST(GENERATE_ARRAY(-89,89,15)) lat,
                UNNEST(GENERATE_ARRAY(-179,179,15)) long
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

    it ('PARENT should reject quadints at zoom 0', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.PARENT(0)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
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

    it ('CHILDREN should reject quadints at zoom 29', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CHILDREN(4611686027017322525)`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
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
        assert.deepEqual(rows[0]['bbox1'],[-90, 0, 0, 66.51326044311186]);
        assert.deepEqual(rows[0]['bbox2'],[-45, 44.840290651397986, -44.6484375, 45.08903556483103]);
        assert.deepEqual(rows[0]['bbox3'],[-45, 44.99976701918129, -44.998626708984375, 45.00073807829068]);
        assert.deepEqual(rows[0]['bbox4'],[-45, 44.999994612636684, -44.99998927116394, 45.00000219906962]);
    });

    it ('ST_GEOGFROMQUADINT_BOUNDARY should work', async () => {
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_GEOGFROMQUADINT_BOUNDARY(12070922) as geog1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_GEOGFROMQUADINT_BOUNDARY(791040491538) as geog2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_GEOGFROMQUADINT_BOUNDARY(12960460429066265) as geog3`;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0]['geog1']['value'],'POLYGON((-45 45.089035564831, -45 44.840290651398, -44.82421875 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -44.82421875 45.089035564831, -45 45.089035564831))');
        assert.equal(rows[0]['geog2']['value'],'POLYGON((-45 45.0007380782907, -45 44.9997670191813, -44.9986267089844 44.9997670191813, -44.9986267089844 45.0007380782907, -45 45.0007380782907))');
        assert.equal(rows[0]['geog3']['value'],'POLYGON((-45 45.0000021990696, -45 44.9999946126367, -44.9999892711639 44.9999946126367, -44.9999892711639 45.0000021990696, -45 45.0000021990696))');
    });

    it ('ST_ASQUADINTPOLYFILL should work', async () => {
        let feature = {
              "type": "Polygon",
              "coordinates": [
                [
                  [
                    -3.6828231811523207,
                    40.45948689837198
                  ],
                  [
                    -3.69655609130857,
                    40.42917828232078
                  ],
                  [
                    -3.7346649169921777,
                    40.42525806690142
                  ],
                  [
                    -3.704452514648415,
                    40.4090520858275
                  ],
                  [
                    -3.7150955200195077,
                    40.38212061782238
                  ],
                  [
                    -3.6790466308593652,
                    40.40251631173469
                  ],
                  [
                    -3.6399078369140625,
                    40.38212061782238
                  ],
                  [
                    -3.6570739746093652,
                    40.41245043754496
                  ],
                  [
                    -3.6206817626953023,
                    40.431791632323645
                  ],
                  [
                    -3.66634368896482,
                    40.42996229798495
                  ],
                  [
                    -3.6828231811523207,
                    40.45948689837198
                  ]
                ]
              ]
          };
        let featureJSON = JSON.stringify(feature);

        let sqlQuery = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.POLYFILL_FROMGEOJSON(@geojson, 10) as polyfill10,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.POLYFILL_FROMGEOJSON(@geojson, 14) as polyfill14`;
        let rows;
        const query = {
            query: sqlQuery,
            params: {geojson: featureJSON},
          };
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0]['polyfill10'], [20870794, 24147594]);
        assert.deepEqual(rows[0]['polyfill14'], [3238783758, 5933353998, 5985782798, 5985779598, 6038208398, 6038205198, 6090637198, 6143065998, 6143062798, 6143069198, 6090640398, 6090643598, 6143072398, 6143075598, 6038214798, 6038217998, 6038221198, 5985792398, 5985789198, 5985785998]);
    });
}); /* QUADKEY integration tests */
