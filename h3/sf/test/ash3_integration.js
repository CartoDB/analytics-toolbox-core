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

describe('*_ASH3 integration tests', () => {
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

    it ('ST_ASH3 returns the proper INT64', async () => {

/**
 * Note, since JS is bad with large numbers, we cast the ints to STRING
 */
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, ST_POINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, ST_POINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL

    -- null inputs
    SELECT 4 AS id, TRY_TO_GEOGRAPHY(NULL) AS geom, 5 as resolution UNION ALL
    SELECT 5 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, -1 as resolution UNION ALL
    SELECT 6 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, 20 as resolution UNION ALL
    SELECT 7 AS id, ST_POINT(-122.0553238, 37.3615593) as geom, NULL as resolution
)
SELECT
    CAST(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geom, resolution) AS STRING) as h3_id
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 7);
        assert.equal(rows[0].H3_ID, "599686042433355775");
        assert.equal(rows[1].H3_ID, "600235711274156031");
        assert.equal(rows[2].H3_ID, "644577696667402240");
        assert.equal(rows[3].H3_ID, null);
        assert.equal(rows[4].H3_ID, null);
        assert.equal(rows[5].H3_ID, null);
        assert.equal(rows[6].H3_ID, null);
    });

    it ('ST_ASH3 returns NULL with non POINT geographies', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, TO_GEOGRAPHY('LINESTRING(0 0, 10 10)') as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, TO_GEOGRAPHY('MULTIPOINT(0 0, 0 10, 10 10, 10 0, 0 0)') as geom, 5 as resolution
)
SELECT
    CAST(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geom, resolution) AS STRING) as h3_id
FROM inputs
ORDER BY id ASC`;
        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows[0].H3_ID, null);
        assert.equal(rows[1].H3_ID, null);
        assert.equal(rows[2].H3_ID, null);
    });

    it ('LONGLAT_ASH3 returns the proper INT64', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, -122.0553238 as longitude, 37.3615593 as latitude, 5 as resolution UNION ALL
    SELECT 2 AS id, -164.991559 as longitude, 30.943387 as latitude, 5 as resolution UNION ALL
    SELECT 3 AS id, 71.52790329909925 as longitude, 46.04189431883772 as latitude, 15 as resolution UNION ALL

    -- null inputs
    SELECT 4 AS id, NULL as longitude, 37.3615593 as latitude, 5 as resolution UNION ALL
    SELECT 5 AS id, -122.0553238 as longitude, NULL as latitude, 5 as resolution UNION ALL
    SELECT 6 AS id, -122.0553238 as longitude, 37.3615593 as latitude, NULL as resolution UNION ALL

    -- world wrapping
    SELECT 7 AS id, -122.0553238 + 360 as longitude, 37.3615593 as latitude, 5 as resolution UNION ALL
    SELECT 8 AS id, -122.0553238 as longitude, 37.3615593 + 360 as latitude, 5 as resolution
)
SELECT
    CAST(${SF_DATABASEID}.${SF_SCHEMA_H3}.LONGLAT_ASH3(longitude, latitude, resolution) AS STRING) as h3_id
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });

        assert.equal(rows.length, 8);
        assert.equal(rows[0].H3_ID, "599686042433355775");
        assert.equal(rows[1].H3_ID, "600235711274156031");
        assert.equal(rows[2].H3_ID, "644577696667402240");
        assert.equal(rows[3].H3_ID, null);
        assert.equal(rows[4].H3_ID, null);
        assert.equal(rows[5].H3_ID, null);
        assert.equal(rows[6].H3_ID, '599686042433355775');
        assert.equal(rows[7].H3_ID, '599686042433355775');
    });

    it ('ST_ASH3_POLYFILL returns the proper INT64s', async () => {
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, TO_GEOGRAPHY('POLYGON((-122.4089866999972145 37.813318999983238, -122.3805436999997056 37.7866302000007224, -122.3544736999993603 37.7198061999978478, -122.5123436999983966 37.7076131999975672, -122.5247187000021967 37.7835871999971715, -122.4798767000009008 37.8151571999998453, -122.4089866999972145 37.813318999983238))') as geom, 9 as resolution UNION ALL
    SELECT 2 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 2 as resolution UNION ALL
    SELECT 3 AS id, TO_GEOGRAPHY('POLYGON((20 20, 20 30, 30 30, 30 20, 20 20))') as geom, 2 as resolution UNION ALL
    -- 4 is a multipolygon containing 2 + 3
    SELECT 4 AS id, TO_GEOGRAPHY('MULTIPOLYGON(((0 0, 0 10, 10 10, 10 0, 0 0)), ((20 20, 20 30, 30 30, 30 20, 20 20)))') as geom, 2 as resolution UNION ALL

    -- NULL and empty
    SELECT 5 AS id, TRY_TO_GEOGRAPHY(NULL) as geom, 2 as resolution UNION ALL
    SELECT 6 AS id, TO_GEOGRAPHY('POLYGON EMPTY') as geom, 2 as resolution UNION ALL

    -- Invalid resolution
    SELECT 7 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, -1 as resolution UNION ALL
    SELECT 8 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, 20 as resolution UNION ALL
    SELECT 9 AS id, TO_GEOGRAPHY('POLYGON((0 0, 0 10, 10 10, 10 0, 0 0))') as geom, NULL as resolution UNION ALL

    -- Other types are not supported
    SELECT 10 AS id, TO_GEOGRAPHY('POINT(0 0)') as geom, 15 as resolution UNION ALL
    SELECT 11 AS id, TO_GEOGRAPHY('MULTIPOINT(0 0, 1 1)') as geom, 15 as resolution UNION ALL
    SELECT 12 AS id, TO_GEOGRAPHY('LINESTRING(0 0, 1 1)') as geom, 15 as resolution UNION ALL
    SELECT 13 AS id, TO_GEOGRAPHY('MULTILINESTRING((0 0, 1 1), (2 2, 3 3))') as geom, 15 as resolution UNION ALL
    SELECT 14 AS id, TO_GEOGRAPHY('GEOMETRYCOLLECTION(POINT(0 0), LINESTRING(1 2, 2 1))') as geom, 15 as resolution

)
SELECT
    ARRAY_SIZE(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3_POLYFILL(geom, resolution)) AS id_count
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 14);
        assert.equal(rows[0].ID_COUNT, 1253);
        assert.equal(rows[1].ID_COUNT, 18);
        assert.equal(rows[2].ID_COUNT, 12);
        assert.equal(rows[3].ID_COUNT, 30);
        assert.equal(rows[4].ID_COUNT, 0);
        assert.equal(rows[5].ID_COUNT, 0);
        assert.equal(rows[6].ID_COUNT, 0);
        assert.equal(rows[7].ID_COUNT, 0);
        assert.equal(rows[8].ID_COUNT, 0);
        assert.equal(rows[9].ID_COUNT, 0);
        assert.equal(rows[10].ID_COUNT, 0);
        assert.equal(rows[11].ID_COUNT, 0);
        assert.equal(rows[12].ID_COUNT, 0);
        assert.equal(rows[13].ID_COUNT, 0);
    });

    it ('ST_ASH3_POLYFILL returns the expected values', async () => {
        /* Any cell should cover only 1 h3 cell at its resolution (itself) */
        /* This query has been splitted in Snowflake to avoid JS memory limits reached*/
        let query = `
        WITH points AS
        (
            SELECT ST_POINT(0, 0) AS geog
        ),
        resolution AS
        (
            SELECT seq4() AS resolution
            FROM TABLE(generator(rowcount => 16))
        ),
        cells AS
        (
            SELECT
                resolution,
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.H3_FROMINT(
                    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geog, resolution)) AS hex_id,
                    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_BOUNDARY(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geog, resolution)) AS boundary
            FROM points, resolution
        ),
        polyfill AS
        (
            SELECT
                *,
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
`;

        let rows;
        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);

        query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.4089866999972145, 37.813318999983238) AS geog
        
        ),
        resolution AS
        (
            SELECT seq4() AS resolution
            FROM TABLE(generator(rowcount => 16))
        ),
        cells AS
        (
            SELECT
                resolution,
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.H3_FROMINT(
                    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geog, resolution)) AS hex_id,
                    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_BOUNDARY(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geog, resolution)) AS boundary
            FROM points, resolution
        ),
        polyfill AS
        (
            SELECT
                *,
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
`;

        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);

        query = `
        WITH points AS
        (
            SELECT ST_POINT(-122.0553238, 37.3615593) AS geog
        ),
        resolution AS
        (
            SELECT seq4() AS resolution
            FROM TABLE(generator(rowcount => 16))
        ),
        cells AS
        (
            SELECT
                resolution,
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.H3_FROMINT(
                    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geog, resolution)) AS hex_id,
                    ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_BOUNDARY(${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3(geog, resolution)) AS boundary
            FROM points, resolution
        ),
        polyfill AS
        (
            SELECT
                *,
                ${SF_DATABASEID}.${SF_SCHEMA_H3}.ST_ASH3_POLYFILL(boundary, resolution) p
            FROM cells
        )
        SELECT
            *
        FROM  polyfill
        WHERE
            ARRAY_SIZE(p) != 1 OR
            GET(p,0) != hex_id;
`;

        await assert.doesNotReject(async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 0);
    });

}); /* *_ASH3 integration tests */
