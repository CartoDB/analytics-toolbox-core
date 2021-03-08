const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('ST_ASQUADINT_POLYFILL integration tests', () => {
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

    it ('ST_ASQUADINT_POLYFILL should work', async () => {
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

        let sqlQuery = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.__POLYFILL_FROMGEOJSON(@geojson, 10) as polyfill10,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.__POLYFILL_FROMGEOJSON(@geojson, 14) as polyfill14`;
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
    
    it ('__POLYFILL_FROMGEOJSON should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.__POLYFILL_FROMGEOJSON(NULL, 10);`;
        await assert.rejects( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });

        let feature = {
            "type": "Polygon",
            "coordinates": [
                [
                    [
                        -3.6828231811523207,
                        40.45948689837198
                    ],
                    [
                        -3.6828231811523207,
                        40.45948689837198
                    ]
                ]
            ]
        };
        let featureJSON = JSON.stringify(feature);

        let sqlQuery = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.__POLYFILL_FROMGEOJSON(@geojson, NULL)`;
        query = {
            query: sqlQuery,
            params: {geojson: featureJSON},
        };
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });

}); /* QUADKEY integration tests */
