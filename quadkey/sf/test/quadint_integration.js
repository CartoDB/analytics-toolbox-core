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

describe('QUADINT integration tests', () => {
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
     
    it ('Should be able to encode/decode quadints at different zooms', async () => {
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
            )
            SELECT *
            FROM 
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.ZXY_FROMQUADINT(
                    ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(zoom, tileX, tileY)) AS decodedQuadkey
                FROM tileContext
            )
            WHERE tileX != GET(decodedQuadkey,'x') OR tileY != GET(decodedQuadkey,'y') OR zoom != GET(decodedQuadkey,'z')`;

        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });
}); /* QUADINT integration tests */
