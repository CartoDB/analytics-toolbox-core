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

describe('DISTANCE integration tests', () => {
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

    it ('Works as expected with invalid input', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid1, '0x85283473fffffff' AS hid2 UNION ALL
    SELECT 2 AS id, '0xff283473fffffff' as hid1, '0x85283473fffffff' AS hid2 UNION ALL
    SELECT 3 AS id, '0x85283473fffffff' as hid1, NULL AS hid2 UNION ALL
    SELECT 4 AS id, '0x85283473fffffff' as hid1, '0xff283473fffffff' AS hid2 UNION ALL

    -- Self
    SELECT 5 AS id, '0x8928308280fffff' as hid1, '0x8928308280fffff' as hid2
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.DISTANCE(hid1, hid2) as distance
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 5);
        assert.equal(rows[0].DISTANCE, null);
        assert.equal(rows[1].DISTANCE, null);
        assert.equal(rows[2].DISTANCE, null);
        assert.equal(rows[3].DISTANCE, null);
        assert.equal(rows[4].DISTANCE, 0);
    });

    it ('Works as expected with valid input', async () => {
        const query = `
WITH distances AS
(
    SELECT seq4() AS distance
    FROM TABLE(generator(rowcount => 5))
),
ids AS
(
    SELECT
        distance,
        '0x8928308280fffff' as hid1,
        hid2.value as hid2
    FROM
        distances,
        lateral FLATTEN(input =>${SF_DATABASEID}.${SF_SCHEMA_H3}.HEXRING('0x8928308280fffff', distance)) hid2
)
SELECT ${SF_DATABASEID}.${SF_SCHEMA_H3}.DISTANCE(hid1, hid2) as calculated_distance, *
FROM ids
WHERE ${SF_DATABASEID}.${SF_SCHEMA_H3}.DISTANCE(hid1, hid2) != distance;
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

}); /* DISTANCE integration tests */
