const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

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

describe('ST_BOUNDARY integration tests', () => {
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
                    console.log('Successfully connected to Snowflake.');
                    // Optional: store the connection ID.
                    connection_ID = conn.getId();
                }
            }
        );
    });

    it ('ST_BOUNDARY should work', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.ST_BOUNDARY(12070922) as geog1,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.ST_BOUNDARY(791040491538) as geog2,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.ST_BOUNDARY(12960460429066265) as geog3`;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        assert.equal(rows.length, 1);      
        assert.equal(JSON.stringify(rows[0]['GEOG1']),'{"coordinates":[[[-45,45.08903556483103],[-45,44.840290651397986],[-44.6484375,44.840290651397986],[-44.6484375,45.08903556483103],[-45,45.08903556483103]]],"type":"Polygon"}');
        assert.equal(JSON.stringify(rows[0]['GEOG2']),'{"coordinates":[[[-45,45.00073807829068],[-45,44.99976701918129],[-44.998626708984375,44.99976701918129],[-44.998626708984375,45.00073807829068],[-45,45.00073807829068]]],"type":"Polygon"}');
        assert.equal(JSON.stringify(rows[0]['GEOG3']),'{"coordinates":[[[-45,45.00000219906962],[-45,44.999994612636684],[-44.99998927116394,44.999994612636684],[-44.99998927116394,45.00000219906962],[-45,45.00000219906962]]],"type":"Polygon"}');
    });

    it ('__GEOJSONBOUNDARY_FROMQUADINT should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.__GEOJSONBOUNDARY_FROMQUADINT(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* ST_BOUNDARY integration tests */

