const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_H3 = process.env.SF_SCHEMA_H3;

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

describe('ISPENTAGON integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_H3) {
            throw "Missing SF_SCHEMA_H3 env variable";
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

    it ('Works as expected', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, '0xff283473fffffff' as hid UNION ALL

    -- Valid parameters
                    -- Hex
    SELECT 3 AS id, '0x8928308280fffff' as hid UNION ALL
                    -- Pentagon
    SELECT 4 AS id, '0x821c07fffffffff' as hid
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ISPENTAGON(hid) as pent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 4);
        assert.equal(rows[0].PENT, false);
        assert.equal(rows[1].PENT, false);
        assert.equal(rows[2].PENT, false);
        assert.equal(rows[3].PENT, true);
    });

}); /* ISPENTAGON integration tests */
