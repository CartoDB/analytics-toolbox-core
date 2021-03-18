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

describe('TOPARENT integration tests', () => {
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

    it ('TOPARENT should work at any level of zoom', async () => {
        let query = `WITH zoomContext AS(
                WITH z AS
                (
                    SELECT seq4()+1 AS z
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
                360*x/10-180 AS long,
                180*y/10-90 AS lat
                FROM z,x,y
                GROUP BY zoom,long,lat
            )
            SELECT *
            FROM 
            (
                SELECT *,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.ST_ASQUADINT(ST_POINT(long, lat), zoom - 1) AS expectedParent,
                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOPARENT(
                    ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.ST_ASQUADINT(ST_POINT(long, lat), zoom),zoom - 1) AS parent
                FROM zoomContext
            )
            WHERE parent != expectedParent`;
        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

    it ('TOPARENT should reject quadints at zoom 0', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOPARENT(0,0)`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });

    it ('TOPARENT should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOPARENT(NULL, 10);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.TOPARENT(322, NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* QUADKEY integration tests */
