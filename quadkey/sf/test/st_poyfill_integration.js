const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');
const fs = require('fs');
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../quadkey_library.js') + '');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_QUADKEY = process.env.SF_SCHEMA_QUADKEY;

function execAsync(connection, sqlText) {
    return new Promise((resolve, reject) => {
        connection.execute({
            sqlText: sqlText,
            complete: (err, stmt, rows) => {
                if (err) {
                    return reject(err);
                } 
                return resolve([stmt, rows]);
            }
        });
    });
}

describe('ST_ASQUADINT_POLYFILL integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_QUADKEY) {
            throw "Missing SF_SCHEMA_QUADKEY env variable";
        }
        connection = snowflake.createConnection( {
            account: process.env.SNOWSQL_ACCOUNT,
            username: process.env.SNOWSQL_USER,
            password: process.env.SNOWSQL_PWD
            }
        );
        connection.connect( 
            function(err, conn) {
                if (err) {
                    console.error('Unable to connect: ' + err.message);
                } 
                else 
                {
                    // Optional: store the connection ID.
                    connection_ID = conn.getId();
                }
            }
        );
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
    
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}._POLYFILL_FROMGEOJSON('${featureJSON}', 10) as polyfill10,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}._POLYFILL_FROMGEOJSON('${featureJSON}', 14) as polyfill14`;
        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        let quadints = geojsonToQuadints(feature, {min_zoom: 10, max_zoom: 10});
        assert.deepEqual(rows[0]['POLYFILL10'].sort(), quadints.map(String).sort());
        assert.deepEqual(rows[0]['POLYFILL10'].sort(), ['12631722', '12664490']);
        quadints = geojsonToQuadints(feature, {min_zoom: 14, max_zoom: 14});
        assert.deepEqual(rows[0]['POLYFILL14'].sort(), quadints.map(String).sort());
        assert.deepEqual(rows[0]['POLYFILL14'].sort(), ['3237735182', '3238259438', '3238259470', '3238259502', '3238259534', '3238259566', '3238783694', '3238783726', '3238783758', '3238783790', '3238783822', '3238783854', '3239308014', '3239308046', '3239308078', '3239832270', '3239832302', '3239832334', '3239832366', '3239832398']);
    });

    it ('__POLYFILL_FROMGEOJSON should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}._POLYFILL_FROMGEOJSON(NULL, 10);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
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
    
        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}._POLYFILL_FROMGEOJSON('${featureJSON}', NULL)`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* ST_ASQUADINT_POLYFILL integration tests */

