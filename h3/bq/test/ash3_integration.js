const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_H3 = process.env.BQ_DATASET_H3;

describe('*_ASH3', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_H3) {
            throw "Missing BQ_DATASET_H3 env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('ST_ASH3 returns the proper INT64', async () => {

/**
 * Note, since JS is bad with large numbers, we cast the ints to STRING
 */
        const query = `
WITH inputs AS
(
    SELECT 1 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, 5 as resolution UNION ALL
    SELECT 2 AS id, ST_GEOGPOINT(-164.991559, 30.943387) as geom, 5 as resolution UNION ALL
    SELECT 3 AS id, ST_GEOGPOINT(71.52790329909925, 46.04189431883772) as geom, 15 as resolution UNION ALL

    -- null inputs
    SELECT 4 AS id, NULL AS geom, 5 as resolution UNION ALL
    SELECT 5 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, -1 as resolution UNION ALL
    SELECT 6 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, 20 as resolution UNION ALL
    SELECT 7 AS id, ST_GEOGPOINT(-122.0553238, 37.3615593) as geom, NULL as resolution
)
SELECT
    CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.ST_ASH3(geom, resolution) AS STRING) as h3_id
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 7);
        assert.equal(rows[0].h3_id, "599686042433355775");
        assert.equal(rows[1].h3_id, "600235711274156031");
        assert.equal(rows[2].h3_id, "644577696667402240");
        assert.equal(rows[3].h3_id, null);
        assert.equal(rows[4].h3_id, null);
        assert.equal(rows[5].h3_id, null);
        assert.equal(rows[6].h3_id, null);
    });

    it ('LONGLAT_ASH3 returns the proper INT64', async () => {

/**
 * Note, since JS is bad with large numbers, we cast the ints to STRING
 */
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
    CAST(\`${BQ_PROJECTID}\`.\`${BQ_DATASET_H3}\`.LONGLAT_ASH3(longitude, latitude, resolution) AS STRING) as h3_id
FROM inputs
ORDER BY id ASC`;

        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 8);
        assert.equal(rows[0].h3_id, "599686042433355775");
        assert.equal(rows[1].h3_id, "600235711274156031");
        assert.equal(rows[2].h3_id, "644577696667402240");
        assert.equal(rows[3].h3_id, null);
        assert.equal(rows[4].h3_id, null);
        assert.equal(rows[5].h3_id, null);
        assert.equal(rows[6].h3_id, '599686042433355775');
        assert.equal(rows[7].h3_id, '599686042433355775');
    });

}); /* *_ASH3 integration tests */
