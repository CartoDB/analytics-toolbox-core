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

describe('TOCHILDREN integration tests', () => {
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

    it ('TOCHILDREN works as expected with invalid data', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.TOCHILDREN(hid, 1) as parent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 2);
        assert.deepEqual(rows[0].parent, []);
        assert.deepEqual(rows[1].parent, []);
    });

    it ('List children correctly', async () => {
        const query = `
WITH ids AS
(
    SELECT
        ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(ST_GEOGPOINT(-122.409290778685, 37.81331899988944), 7) AS hid
)
SELECT
    ARRAY_LENGTH(${SF_DATABASEID}.${SF_SCHEMA_H3}.TOCHILDREN(hid, 8)) AS length_children,
    ARRAY_LENGTH(${SF_DATABASEID}.${SF_SCHEMA_H3}.TOCHILDREN(hid, 9)) AS length_grandchildren
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].length_children, 7);
        assert.equal(rows[0].length_grandchildren, 49);
    });

    it ('Same resolution lists self', async () => {
        const query = `
WITH ids AS
(
    SELECT 608692970266296319 as hid
)
SELECT
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.TOCHILDREN(hid, 7) AS self_children
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].self_children, [ 608692970266296319 ]);
    });

    it ('Coarser resolution returns empty array', async () => {
        const query = `
WITH ids AS
(
    SELECT
        ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(ST_GEOGPOINT(-122.409290778685, 37.81331899988944), 7) AS hid
)
SELECT
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.TOCHILDREN(hid, 6) AS top_children
FROM ids
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].top_children, [ ]);
    });

}); /* TOCHILDREN integration tests */
