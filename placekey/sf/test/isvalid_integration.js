const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_PLACEKEY = process.env.SF_SCHEMA_PLACEKEY;

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

describe('ISVALID', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_PLACEKEY) {
            throw "Missing SF_SCHEMA_PLACEKEY env variable";
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
    SELECT 1 AS id, NULL as pk UNION ALL
    SELECT 2 AS id, '@abc' as pk UNION ALL
    SELECT 3 AS id, 'abc-xyz' as pk UNION ALL
    SELECT 4 AS id, 'abcxyz234' as pk UNION ALL
    SELECT 5 AS id, 'abc-345@abc-234-xyz' as pk UNION ALL
    SELECT 6 AS id, 'ebc-345@abc-234-xyz' as pk UNION ALL
    SELECT 7 AS id, 'bcd-345@' as pk UNION ALL
    SELECT 8 AS id, '22-zzz@abc-234-xyz' as pk UNION ALL

    -- Valid parameters
    SELECT 9 AS id, 'abc-234-xyz' as pk UNION ALL
    SELECT 10 AS id, '@abc-234-xyz' as pk UNION ALL
    SELECT 11 AS id, 'bcd-2u4-xez' as pk UNION ALL
    SELECT 12 AS id, 'zzz@abc-234-xyz' as pk UNION ALL
    SELECT 13 AS id, '222-zzz@abc-234-xyz' as pk
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_PLACEKEY}.ISVALID(pk) as valid
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 13);
        assert.equal(rows[0].VALID, false);
        assert.equal(rows[1].VALID, false);
        assert.equal(rows[2].VALID, false);
        assert.equal(rows[3].VALID, false);
        assert.equal(rows[4].VALID, false);
        assert.equal(rows[5].VALID, false);
        assert.equal(rows[6].VALID, false);
        assert.equal(rows[7].VALID, false);
        assert.equal(rows[8].VALID, true);
        assert.equal(rows[9].VALID, true);
        assert.equal(rows[10].VALID, true);
        assert.equal(rows[11].VALID, true);
        assert.equal(rows[12].VALID, true);
    });

}); /* PLACEKEY_ISVALID integration tests */
