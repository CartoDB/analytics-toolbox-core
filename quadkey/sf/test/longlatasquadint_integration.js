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

describe('LONGLAT_ASQUADINT integration tests', () => {
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

    it ('LONGLAT_ASQUADINT should not fail at any level of zoom', async () => {
        let query = `WITH zoomContext AS(
                WITH z AS
                (
                    SELECT seq4() AS z
                    FROM TABLE(generator(rowcount => 30))
                ),
                x AS
                (
                SELECT seq4() AS x
                    FROM TABLE(generator(rowcount => 10))
                ),
                y as
                (
                SELECT seq4() AS y
                    FROM TABLE(generator(rowcount => 10))
                )
                SELECT z as zoom,
                360*x/10-180 AS long,
                180*y/10-90 AS lat
                FROM z,x,y
                GROUP BY zoom,long,lat
            )
            SELECT *
            FROM 
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.LONGLAT_ASQUADINT(long, lat, zoom)
                FROM zoomContext
            )`;

        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });

    it ('Should fail to encode quadints at zooms bigger than 29 or smaller than 0', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.LONGLAT_ASQUADINT(100, 100, 30)`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.LONGLAT_ASQUADINT(100, 100, -1)`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });

    it ('LONGLAT_ASQUADINT should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.LONGLAT_ASQUADINT(NULL, 10, 10);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.LONGLAT_ASQUADINT(10, NULL, 10);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.LONGLAT_ASQUADINT(10, 10, NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* LONGLAT_ASQUADINT integration tests */