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

describe('INT conversions integration tests', () => {
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

    it ('H3_ASINT returns the proper INT64', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, ST_POINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, ST_POINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL
    SELECT 4 AS id, TRY_TO_GEOGRAPHY(NULL) AS geom, 5 as resolution
)
SELECT
${SF_DATABASEID}.${SF_SCHEMA_H3}.H3_ASINT(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geom, resolution)) as h3_id
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 4);
        assert.equal(rows[0].H3_ID, 599686042433355800);
        assert.equal(rows[1].H3_ID, 600235711274156000);
        assert.equal(rows[2].H3_ID, 644577696667402200);
        assert.equal(rows[3].H3_ID, null);
    });

    it ('H3_ASINT returns the proper INT64', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, ST_POINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, ST_POINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL
    SELECT 4 AS id, NULL AS geom, 5 as resolution
)
SELECT
    *
FROM inputs
WHERE
    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geom, resolution) !=
        ${SF_DATABASEID}.${SF_SCHEMA_H3}.H3_FROMINT(    
            ${SF_DATABASEID}.${SF_SCHEMA_H3}.H3_ASINT(
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geom, resolution)))
`;
        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

}); /* INT conversions integration tests */
