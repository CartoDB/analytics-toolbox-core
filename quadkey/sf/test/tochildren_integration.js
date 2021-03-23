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

describe('TOCHILDREN integration tests', () => {
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
  
    it ('TOCHILDREN should work at any level of zoom', async () => {
        let query = `WITH tileContext AS(
            WITH z AS
            (
                SELECT seq4() AS z
                    FROM TABLE(generator(rowcount => 29))
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
                CAST((POW(2,zoom)-1)*x/10 AS INT) AS tileX,
                CAST((POW(2,zoom)-1)*y/10 AS INT) AS tileY
                FROM z,x,y
                GROUP BY zoom,tileX,tileY
            ),
            expectedQuadintContext AS
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(zoom, tileX, tileY) AS expectedQuadint
                FROM tileContext
            ),
            childrenContext AS
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOCHILDREN(expectedQuadint, zoom + 1) AS children
                FROM expectedQuadintContext 
            )
            SELECT *
            FROM 
            (
                SELECT expectedQuadint,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOPARENT(child.value, zoom) AS currentQuadint
                FROM childrenContext, LATERAL FLATTEN(input => children) AS child
            )
            WHERE currentQuadint != expectedQuadint`;
        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

    it ('TOCHILDREN should reject quadints at zoom 29', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOCHILDREN(4611686027017322525,30)`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });

    it ('TOCHILDREN should fail with NULL arguments', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOCHILDREN(NULL, 1);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOCHILDREN(322, NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* QUADKEY integration tests */
