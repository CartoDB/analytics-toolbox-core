const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_QUADKEY = process.env.BQ_DATASET_QUADKEY;

describe('QUADKEY integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_QUADKEY) {
            throw "Missing BQ_DATASET_QUADKEY env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });
  
    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('Should be able to encode/decode quadints at different zooms', async () => {
        let tilesPerLevel, x, y;
        for(let z = 1; z < 30; z = z + 7)
        {
            tilesPerLevel = 2 << (z - 1);

            x = 0;
            y = 0;
            let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ZXY_FROM_QUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROM_ZXY(${z}, ${x}, ${y})) as zxy;`;

            let rows;
            await assert.doesNotReject( async () => {
                const [job] = await client.createQueryJob({ query: query });
                [rows] = await job.getQueryResults();
            });
            assert.equal(rows.length, 1);
            assert.ok(z === rows[0].zxy.z && x === rows[0].zxy.x && y === rows[0].zxy.y);

            x = tilesPerLevel - 1;
            y = tilesPerLevel - 1;
            query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ZXY_FROM_QUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROM_ZXY(${z}, ${x}, ${y})) as zxy;`;

            await assert.doesNotReject( async () => {
                const [job] = await client.createQueryJob({ query: query });
                [rows] = await job.getQueryResults();
            });
            assert.equal(rows.length, 1);
            assert.ok(z === rows[0].zxy.z && x === rows[0].zxy.x && y === rows[0].zxy.y);
        }
    });

    it ('Should be able to encode/decode between quadint and quadkey at any level of zoom', async () => {
        let tilesPerLevel, x, y;
        for(let z = 1; z < 30; z = z + 7)
        {
            tilesPerLevel = 2 << (z - 1);

            x = 0;
            y = 0;
            let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ZXY_FROM_QUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROM_QUADKEY(
                    \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROM_QUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROM_ZXY(${z}, ${x}, ${y})))) as zxy;`;

            let rows;
            await assert.doesNotReject( async () => {
                const [job] = await client.createQueryJob({ query: query });
                [rows] = await job.getQueryResults();
            });
            assert.equal(rows.length, 1);
            assert.ok(z === rows[0].zxy.z && x === rows[0].zxy.x && y === rows[0].zxy.y);

            x = tilesPerLevel - 1;
            y = tilesPerLevel - 1;
            query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ZXY_FROM_QUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROM_QUADKEY(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADKEY_FROM_QUADINT(
                \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.QUADINT_FROM_ZXY(${z}, ${x}, ${y})))) as zxy;`;

            await assert.doesNotReject( async () => {
                const [job] = await client.createQueryJob({ query: query });
                [rows] = await job.getQueryResults();
            });
            assert.equal(rows.length, 1);
            assert.ok(z === rows[0].zxy.z && x === rows[0].zxy.x && y === rows[0].zxy.y);
        }
    });

    it ('Parent should work at any level of zoom', async () => {
        let z, lat, lng;
        for(z = 5; z < 30; z = z + 20)
        {
            for(lat = -90; lat <= 90; lat = lat + 120)
            {
                for(lng = -180; lng <= 180; lng = lng + 200)
                {
                    let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(${lng}, ${lat}),${z - 1}) as currentParent;`;
                    let rows;
                    await assert.doesNotReject( async () => {
                        const [job] = await client.createQueryJob({ query: query });
                        [rows] = await job.getQueryResults();
                    });
                    assert.equal(rows.length, 1);
                    let currentParent = rows[0].currentParent;

                    query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.PARENT(
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(${lng}, ${lat}),${z})) as parent;`;
                    rows;
                    await assert.doesNotReject( async () => {
                        const [job] = await client.createQueryJob({ query: query });
                        [rows] = await job.getQueryResults();
                    });
                    assert.equal(rows.length, 1);
                    assert.equal(rows[0].parent, currentParent);
                }
            }
        }
    });

    it ('Children should work at any level of zoom', async () => {
        let z, lat, lng, cont;
        for(z = 5; z < 30; z = z + 20)
        {
            for(lat = -90; lat <= 90; lat = lat + 120)
            {
                for(lng = -180; lng <= 180; lng = lng + 200)
                {
                    let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(${lng}, ${lat}),${z + 1}) as currentChild;`;
                    let rows;
                    await assert.doesNotReject( async () => {
                        const [job] = await client.createQueryJob({ query: query });
                        [rows] = await job.getQueryResults();
                    });
                    assert.equal(rows.length, 1);
                    let currentChild = rows[0].currentChild;

                    query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.CHILDREN(
                        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_QUADKEY}\`.ST_ASQUADINT(ST_GEOGPOINT(${lng}, ${lat}),${z})) as children;`;
                    rows;
                    await assert.doesNotReject( async () => {
                        const [job] = await client.createQueryJob({ query: query });
                        [rows] = await job.getQueryResults();
                    });
                    assert.equal(rows.length, 1);
                    assert.equal(rows[0].children.length, 4);
                    let childs = rows[0].children;
                    cont = 0;
                    childs.forEach((element) => {
                        if(currentChild === element)
                        {
                            ++cont;
                        }
                    });
                    assert.equal(cont,1);
                }
            }
        }
    });
}); /* QUADKEY integration tests */
