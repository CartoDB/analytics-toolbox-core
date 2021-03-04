const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_S2 = process.env.BQ_DATASET_S2;

describe('S2 integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_S2) {
            throw "Missing BQ_DATASET_S2 env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('KEY / ID conversions should work', async () => {
        let level = 10;
        let latitude = 10;
        let longitude = -20;
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.KEY_FROMLONGLAT(${longitude},${latitude},${level}) as key;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        const quadkey = rows[0].key;

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.KEY_FROMID(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMKEY("${quadkey}")) as key;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(quadkey, rows[0].key);

        level = 11;
        latitude = 15;
        longitude = -25;
        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMLONGLAT(${longitude},${latitude},${level}) as id;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        const s2Id = rows[0].id;

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.ID_FROMKEY(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.KEY_FROMID(${s2Id})) as id;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(s2Id, rows[0].id);
    });

    it('Boundary functions should work', async() => {
        const level = 18;
        const latitude = -14;
        const longitude = 125;
        const bounds = {
            "type": "Polygon",
            "coordinates": [[
                [124.99991607494462, -14.000016145055083],
                [124.99991607494462, -13.99970528488021],
                [125.0002604046465, -13.999648690569117],
                [125.0002604046465, -13.999959549588995],
                [124.99991607494462, -14.000016145055083]
            ]]
        };

        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.KEY_FROMLONGLAT(${longitude},${latitude},${level}) as key;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        const quadkey = rows[0].key;

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.GEOJSONBOUNDARY_FROMKEY("${quadkey}") as boundary;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        let resultBoundary = JSON.parse(rows[0].boundary);
        assert.equal(rows.length, 1);
        assert.deepEqual(bounds, resultBoundary);

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.GEOJSONBOUNDARY_FROMKEY(
            \`${BQ_PROJECTID}\`.\`${BQ_DATASET_S2}\`.S2_FROMLONGLAT(${longitude},${latitude},${level})) as boundary;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        resultBoundary = JSON.parse(rows[0].boundary);
        assert.equal(rows.length, 1);
        assert.deepEqual(bounds, resultBoundary);
    });
}); /* S2 integration tests */
