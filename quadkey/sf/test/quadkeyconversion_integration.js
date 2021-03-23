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

describe('QUADKEY conversions integration tests', () => {
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

    it ('QUADKEY conversion should work', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(2, 1, 1)) as quadkey1,
                            ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(6, 40, 55)) as quadkey2,
                            ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(12, 1960, 3612)) as quadkey3,
                            ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(18, 131621, 65120)) as quadkey4,
                            ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(24, 9123432, 159830174)) as quadkey5,
                            ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                                ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(29, 389462872, 207468912)) as quadkey6`;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].QUADKEY1, "03");
        assert.equal(rows[0].QUADKEY2, "321222");
        assert.equal(rows[0].QUADKEY3, "233110123200");
        assert.equal(rows[0].QUADKEY4, "102222223002300101");
        assert.equal(rows[0].QUADKEY5, "300012312213011021123220");
        assert.equal(rows[0].QUADKEY6, "12311021323123033301303231000");
    });

    it ('Should be able to encode/decode between quadint and quadkey at any level of zoom', async () => {
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
                    ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMQUADKEY(
                        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(
                        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADINT_FROMZXY(zoom, tileX, tileY)))) AS decodedQuadkey
                FROM tileContext
            )
            WHERE tileX != GET(decodedQuadkey,'x') OR tileY != GET(decodedQuadkey,'y') OR zoom != GET(decodedQuadkey,'z')`;

        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

    it ('QUADKEY_FROMQUADINT should fail with NULL argument', async () => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.QUADKEY_FROMQUADINT(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* QUADKEY conversions integration tests */
