const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_SKEL = process.env.SF_SCHEMA_SKEL;

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

describe('SKEL integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_SKEL) {
            throw "Missing SF_SCHEMA_SKEL env variable";
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
  
    it ('Returns the proper version', async () => {
        const query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_SKEL}.VERSION() versioncol;`;
        let statement, rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].VERSIONCOL, '1.0.0');
    });

    it('Adds correctly', async () => {
        const query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_SKEL}.EXAMPLE_ADD(5) as addition;`;
        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].ADDITION, 6);
    });
}); /* SKEL integration tests */
