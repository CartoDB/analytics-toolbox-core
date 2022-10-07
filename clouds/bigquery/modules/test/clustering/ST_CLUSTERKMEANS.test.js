const { runQuery } = require('../../../common/test-utils');

const points1FixturesOut = require('./fixtures/st_clusterkmeans_points1_out');
const points2FixturesOut = require('./fixtures/st_clusterkmeans_points2_out');
const points3FixturesOut = require('./fixtures/st_clusterkmeans_points3_out');

test('ST_CLUSTERKMEANS should work', async () => {
    const query = `SELECT
        \`@@BQ_DATASET@@.ST_CLUSTERKMEANS\`([ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 1), ST_GEOGPOINT(5, 0), ST_GEOGPOINT(1, 0)], 2) as clusterKMeans1,
        \`@@BQ_DATASET@@.ST_CLUSTERKMEANS\`([ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 1), ST_GEOGPOINT(5, 0), ST_GEOGPOINT(1, 0), ST_GEOGPOINT(0, 1), ST_GEOGPOINT(5, 0), ST_GEOGPOINT(1, 19), ST_GEOGPOINT(12, 1), ST_GEOGPOINT(9, 2), ST_GEOGPOINT(1, 10), ST_GEOGPOINT(-3, 1), ST_GEOGPOINT(5, 5), ST_GEOGPOINT(8, 6), ST_GEOGPOINT(10, 10), ST_GEOGPOINT(-3, -5), ST_GEOGPOINT(6, 5), ST_GEOGPOINT(-8, 9), ST_GEOGPOINT(1, -10), ST_GEOGPOINT(2, -2), ST_GEOGPOINT(0, 0), ST_GEOGPOINT(3, 10)], 3) as clusterKMeans2,
        \`@@BQ_DATASET@@.ST_CLUSTERKMEANS\`([ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 1), ST_GEOGPOINT(5, 0), ST_GEOGPOINT(1, 0), ST_GEOGPOINT(0, 1), ST_GEOGPOINT(5, 0), ST_GEOGPOINT(1, 19), ST_GEOGPOINT(12, 1), ST_GEOGPOINT(9, 2), ST_GEOGPOINT(1, 10), ST_GEOGPOINT(-3, 1), ST_GEOGPOINT(5, 5), ST_GEOGPOINT(8, 6), ST_GEOGPOINT(10, 10), ST_GEOGPOINT(-3, -5), ST_GEOGPOINT(6, 5), ST_GEOGPOINT(-8, 9), ST_GEOGPOINT(1, -10), ST_GEOGPOINT(2, -2), ST_GEOGPOINT(0, 0), ST_GEOGPOINT(3, 10)], 5) as clusterKMeans3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].clusterKMeans1).toEqual(JSON.parse(points1FixturesOut.value));
    expect(rows[0].clusterKMeans2).toEqual(JSON.parse(points2FixturesOut.value));
    expect(rows[0].clusterKMeans3).toEqual(JSON.parse(points3FixturesOut.value));
});

test('ST_CLUSTERKMEANS should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT
        \`@@BQ_DATASET@@.ST_CLUSTERKMEANS\`(NULL, 2) as clusterKMeans1
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].clusterKMeans1).toEqual([]);
});

test('ST_CLUSTERKMEANS default values should work', async () => {
    const query = `SELECT
        \`@@BQ_DATASET@@.ST_CLUSTERKMEANS\`([ST_GEOGPOINT(9,10), ST_GEOGPOINT(11,12), ST_GEOGPOINT(10,10), ST_GEOGPOINT(13,10), ST_GEOGPOINT(15,8), ST_GEOGPOINT(13,6), ST_GEOGPOINT(9,10), ST_GEOGPOINT(11,12), ST_GEOGPOINT(10,10), ST_GEOGPOINT(13,10), ST_GEOGPOINT(15,8), ST_GEOGPOINT(13,6), ST_GEOGPOINT(9,10), ST_GEOGPOINT(11,12), ST_GEOGPOINT(10,10), ST_GEOGPOINT(13,10), ST_GEOGPOINT(15,8), ST_GEOGPOINT(13,6)], 3) as defaultValue,
        \`@@BQ_DATASET@@.ST_CLUSTERKMEANS\`([ST_GEOGPOINT(9,10), ST_GEOGPOINT(11,12), ST_GEOGPOINT(10,10), ST_GEOGPOINT(13,10), ST_GEOGPOINT(15,8), ST_GEOGPOINT(13,6), ST_GEOGPOINT(9,10), ST_GEOGPOINT(11,12), ST_GEOGPOINT(10,10), ST_GEOGPOINT(13,10), ST_GEOGPOINT(15,8), ST_GEOGPOINT(13,6), ST_GEOGPOINT(9,10), ST_GEOGPOINT(11,12), ST_GEOGPOINT(10,10), ST_GEOGPOINT(13,10), ST_GEOGPOINT(15,8), ST_GEOGPOINT(13,6)], NULL) as nullParam
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].defaultValue).toEqual(rows[0].nullParam);
});