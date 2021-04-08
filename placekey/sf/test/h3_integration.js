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

describe('Conversion to h3', () => {
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
  
    it ('PLACEKEY_ASH3 Returns null with invalid input', async () => {
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
    SELECT 8 AS id, '22-zzz@abc-234-xyz' as pk
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_PLACEKEY}.PLACEKEY_ASH3(pk) as h3
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 8);
        assert.equal(rows[0].H3, null);
        assert.equal(rows[1].H3, null);
        assert.equal(rows[2].H3, null);
        assert.equal(rows[3].H3, null);
        assert.equal(rows[4].H3, null);
        assert.equal(rows[5].H3, null);
        assert.equal(rows[6].H3, null);
        assert.equal(rows[7].H3, null);
    });

    it ('H3_ASPLACEKEY Returns null with invalid input', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 'ff283473fffffff' as hid
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_PLACEKEY}.H3_ASPLACEKEY(hid) as placekey
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 2);
        assert.equal(rows[0].PLACEKEY, null);
        assert.equal(rows[1].PLACEKEY, null);
    });

    it ('PLACEKEY_ASH3 and H3_ASPLACEKEY work as expected', async () => {
        const query = `
WITH ids AS
(
    SELECT 1 AS id, '@c6z-c2g-dgk' AS pk, '8a62e9d08a1ffff' AS h3 UNION ALL
    SELECT 2 AS id, '@63m-vc4-z75' AS pk, '8a2a9c580577fff' AS h3 UNION ALL
    SELECT 3 AS id, '@7qg-xf9-j5f' AS pk, '8a3c9ea2bd4ffff' AS h3 UNION ALL
    SELECT 4 AS id, '@bhm-9m8-gtv' AS pk, '8a5b4c1047b7fff' AS h3 UNION ALL
    SELECT 5 AS id, '@h5z-gcq-kvf' AS pk, '8a8e8116a6d7fff' AS h3 UNION ALL
    SELECT 6 AS id, '@7v4-m2p-3t9' AS pk, '8a3e0ba6659ffff' AS h3 UNION ALL
    SELECT 7 AS id, '@hvb-5d7-92k' AS pk, '8a961652a407fff' AS h3 UNION ALL
    SELECT 8 AS id, '@ab2-k43-xqz' AS pk, '8a01262c914ffff' AS h3 UNION ALL
    SELECT 9 AS id, '@adk-f8f-dn5' AS pk, '8a022498c737fff' AS h3 UNION ALL
    SELECT 10 AS id, '@jpx-58g-p9z' AS pk, '8a9f5b890cdffff' AS h3 UNION ALL
    SELECT 11 AS id, '@4dd-yfx-6rk' AS pk, '8a1812483227fff' AS h3 UNION ALL
    SELECT 12 AS id, '@crb-3nn-zzz' AS pk, '8a68ed22128ffff' AS h3
)
SELECT
    *
FROM ids
WHERE
    ${SF_DATABASEID}.${SF_SCHEMA_PLACEKEY}.PLACEKEY_ASH3(pk) != h3 OR
    ${SF_DATABASEID}.${SF_SCHEMA_PLACEKEY}.H3_ASPLACEKEY(h3) != pk
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

}); /* h3 integration tests */
