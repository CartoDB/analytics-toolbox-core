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

describe('QUADKEY integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_QUADKEY) {
            throw "Missing SF_SCHEMA_QUADKEY env variable";
        }
        connection = snowflake.createConnection( {
            account: process.env.SF_ACCOUNT,
            username: process.env.SF_USERNAME,
            password: process.env.SF_PASSWORD
            }
        );
        connection.connect( 
            function(err, conn) {
                if (err) {
                    console.error('Unable to connect: ' + err.message);
                    } 
                else {
                    console.log('Successfully connected to Snowflake.');
                    // Optional: store the connection ID.
                    connection_ID = conn.getId();
                    }
                }
            );
    });
  
    it ('Returns the proper version', async () => {
        const query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.VERSION() versioncol;`;
        let statement, rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].VERSIONCOL, 1);
    });
}); /* QUADKEY integration tests */
