const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_S2 = process.env.SF_SCHEMA_S2;

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

describe('HILBERTQUADKEY conversion integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_S2) {
            throw "Missing SF_SCHEMA_S2 env variable";
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
  
    it ('KEY / ID conversions should work', async () => {
        let query = `
        WITH zoomContext AS(
            WITH z AS
            (
                SELECT seq4() + 1 AS z
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
        ),
        idContext AS (
            SELECT ${SF_DATABASEID}.${SF_SCHEMA_S2}.LONGLAT_ASID(long, lat, zoom) AS expectedID
            FROM zoomContext
        )
        SELECT *
        FROM 
        (
            SELECT *,
            ${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY(
                ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(expectedID)) AS decodedID
            FROM idContext
        )
        WHERE decodedID != expectedID`;

        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

    it('Quadkey to S2 id static conversions', async() => {
        let query = `SELECT CAST(${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY('4/12') AS STRING) AS id1,
        CAST(${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY('2/02300033') AS STRING) AS id2,
        CAST(${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY('3/03131200023201') AS STRING) AS id3,
        CAST(${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY('5/0001221313222222120') AS STRING) AS id4,
        CAST(${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY('2/0221200002312111222332101') AS STRING) AS id5,
        CAST(${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY('5/1331022022103232320303230131') AS STRING) AS id6`;

        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].ID1,'-8286623314361712640');
        assert.equal(rows[0].ID2,'5008548143403368448');
        assert.equal(rows[0].ID3,'7416309021449125888');
        assert.equal(rows[0].ID4,'-6902629179221606400');
        assert.equal(rows[0].ID5,'4985491052606295040');
        assert.equal(rows[0].ID6,'-5790199077674720336');
    });

    it('S2 id to quadkey static conversions', async() => {
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(-5062045981164437504) AS key1,
        ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(5159154848129613824) AS key2,
        ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(3776858106818985984) AS key3,
        ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(-6531506317872332800) AS key4,
        ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(7380675754284404736) AS key5,
        ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(1996857078240356732) AS key6`;

        let rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].KEY1,'5/303');
        assert.equal(rows[0].KEY2,'2/033030');
        assert.equal(rows[0].KEY3,'1/220311003003');
        assert.equal(rows[0].KEY4,'5/022231231230313331');
        assert.equal(rows[0].KEY5,'3/030312231223330330032232');
        assert.equal(rows[0].KEY6,'0/31312302011313121331323110233');
    });

    it ('HILBERTQUADKEY conversions should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_S2}.ID_FROMHILBERTQUADKEY(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_S2}.HILBERTQUADKEY_FROMID(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* S2 integration tests */
