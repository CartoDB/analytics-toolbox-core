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
        assert.deepEqual(rows[0]['polyfill10'].sort(), [12631722, 12664490]);
        assert.deepEqual(rows[0]['polyfill14'].sort(), [3237735182, 3238259438, 3238259470, 3238259502, 3238259534, 3238259566, 3238783694, 3238783726, 3238783758, 3238783790, 3238783822, 3238783854, 3239308014, 3239308046, 3239308078, 3239832270, 3239832302, 3239832334, 3239832366, 3239832398]);
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
