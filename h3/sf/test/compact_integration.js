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

describe('COMPACT / UNCOMPACT integration tests', () => {
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

    it ('Work as expected with NULLish values', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as v UNION ALL
    SELECT 2 AS id, ARRAY_CONSTRUCT() as v
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.COMPACT(NULL) as c,
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.UNCOMPACT(NULL, 5) as u
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        assert.equal(rows.length, 2);
        assert.deepEqual(rows[0].C, []);
        assert.deepEqual(rows[0].U, []);
        assert.deepEqual(rows[1].C, []);
        assert.deepEqual(rows[1].U, []);
    });

    it ('Work with polyfill arrays', async () => {
        const query = `
WITH poly AS
(
    SELECT ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3_POLYFILL(TO_GEOGRAPHY('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))'), 9) AS v
)
SELECT
    ARRAY_SIZE(v) AS original,
    ARRAY_SIZE(${SF_DATABASEID}.${SF_SCHEMA_H3}.COMPACT(v)) AS compacted,
    ARRAY_SIZE(${SF_DATABASEID}.${SF_SCHEMA_H3}.UNCOMPACT(${SF_DATABASEID}.${SF_SCHEMA_H3}.COMPACT(v), 9)) AS uncompacted
FROM poly
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].ORIGINAL, 1253);
        assert.equal(rows[0].COMPACTED, 209);
        assert.equal(rows[0].UNCOMPACTED, 1253);
    });

}); /* COMPACT / UNCOMPACT integration tests */
