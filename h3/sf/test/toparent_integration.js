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

describe('TOPARENT integration tests', () => {
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

    it ('TOPARENT works as expected with invalid data', async () => {
        const query = `
WITH ids AS
(
    -- Invalid parameters
    SELECT 1 AS id, NULL as hid UNION ALL
    SELECT 2 AS id, 0xff283473fffffff as hid
)
SELECT
    id,
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.TOPARENT(hid, 1) as parent
FROM ids
ORDER BY id ASC
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 2);
        assert.equal(rows[0].parent, null);
        assert.equal(rows[1].parent, null);
    });

    it ('Equivalent to previous resolution level', async () => {
    /* From h3-js tests:
        // NB: This test will not work with every hexagon, it has to be a location
        // that does not fall in the margin of error between the 7 children and
        // the parent's true boundaries at every resolution
     */
        const query = `
WITH ids AS
(
    SELECT
        ST_GEOGPOINT(-122.409290778685, 37.81331899988944) as point,
        resolution
    FROM UNNEST(GENERATE_ARRAY(1, 10, 1)) resolution
)
SELECT
    *
FROM ids
WHERE
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(point, resolution) != ${SF_DATABASEID}.${SF_SCHEMA_H3}.TOPARENT(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(point, resolution + 1), resolution) OR
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(point, resolution) != ${SF_DATABASEID}.${SF_SCHEMA_H3}.TOPARENT(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(point, resolution + 2), resolution)
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

}); /* TOPARENT integration tests */
