const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_S2 = process.env.SF_SCHEMA_S2;

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

describe('ST_BOUNDARY integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_S2) {
            throw "Missing SF_SCHEMA_S2 env variable";
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
  
    it('ST_BOUNDARY functions should work', async() => {
        const level = 18;
        const latitude = -14;
        const longitude = 125;
        const bounds = {
            "coordinates": [
              [
                [
                  124.99991607494462,
                  -14.000016145055083
                ],
                [
                  124.99991607494462,
                  -13.99970528488021
                ],
                [
                  125.0002604046465,
                  -13.999648690569117
                ],
                [
                  125.0002604046465,
                  -13.999959549588995
                ],
                [
                  124.99991607494462,
                  -14.000016145055083
                ]
              ]
            ],
            "type": "Polygon"
          };

        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_S2}.ST_BOUNDARY(
            ${SF_DATABASEID}.${SF_SCHEMA_S2}.LONGLAT_ASID(${longitude},${latitude},${level})) as boundary;`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(JSON.stringify(rows[0].BOUNDARY), JSON.stringify(bounds));
    });

    it ('ST_BOUNDARY should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_S2}.ST_BOUNDARY(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* S2 integration tests */
