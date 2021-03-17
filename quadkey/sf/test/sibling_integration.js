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

describe('SIBLING integration tests', () => {
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
                    console.log('Successfully connected to Snowflake.');
                    // Optional: store the connection ID.
                    connection_ID = conn.getId();
                }
            }
        );
    });

    it ('SIBLING should work at any level of zoom', async () => {
        let query = `WITH tileContext AS(
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
            rightSiblingContext AS
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.SIBLING(expectedQuadint,'right') AS rightSibling
                FROM expectedQuadintContext 
            ),
            upSiblingContext AS
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.SIBLING(rightSibling,'up') AS upSibling
                FROM rightSiblingContext 
            ),
            leftSiblingContext AS
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.SIBLING(upSibling,'left') AS leftSibling
                FROM upSiblingContext 
            ),
            downSiblingContext AS
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.SIBLING(leftSibling,'down') AS downSibling
                FROM leftSiblingContext 
            )
            SELECT *
            FROM downSiblingContext
            WHERE downSibling != expectedQuadint`;

        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

    it ('SIBLING should fail if any NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.SIBLING(NULL, 'up');`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.SIBLING(322, NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });

}); /* SIBLING integration tests */
