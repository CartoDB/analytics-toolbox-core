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

describe('BBOX integration tests', () => {
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

    it ('BBOX should work', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.BBOX(162) as bbox1,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.BBOX(12070922) as bbox2,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.BBOX(791040491538) as bbox3,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.BBOX(12960460429066265) as bbox4`;
        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].BBOX1,[-90, 0, 0, 66.51326044311186]);
        assert.deepEqual(rows[0].BBOX2,[-45, 44.84029065139799, -44.6484375, 45.08903556483103]);
        assert.deepEqual(rows[0].BBOX3,[-45, 44.99976701918129, -44.99862670898438, 45.00073807829068]);
        assert.deepEqual(rows[0].BBOX4,[-45, 44.99999461263668, -44.99998927116394, 45.00000219906962]);
    });

    it ('BBOX should fail with NULL argument', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.BBOX(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* BBOX integration tests */