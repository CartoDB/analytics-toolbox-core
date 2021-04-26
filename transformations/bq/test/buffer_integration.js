const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TRANSFORMATIONS = process.env.BQ_DATASET_TRANSFORMATIONS;

describe('ST_BUFFER integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_TRANSFORMATIONS) {
            throw "Missing BQ_DATASET_TRANSFORMATIONS env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('BUFFER should work', async () => {
        let feature = {
             "type": "Feature",
             "geometry": {
                "type": "Point",
                "coordinates": [-100, 50]
            }
        };
        featureJSON = JSON.stringify(feature);
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.__BUFFER('${featureJSON}', 1, 'kilometers', 10) as buffer;`;
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        let resultFeature = JSON.parse(rows[0].buffer);
        let expectedFeature = {
        "type":"Polygon",
            "coordinates":[[[-99.98600905898492,49.99999915887084],[-99.98618090629817,50.00140602642508],[-99.9866930551538,50.002778291895005],[-99.987532921484,50.004082161177266],[-99.98867984621796,50.005285521867904],[-99.99010560189694,50.00635873464321],[-99.99177508639131,50.007275363919106],[-99.99364718676895,50.00801282971553],[-99.99567579208941,50.008552964583245],[-99.997810930141,50.00888246178852],[-100,50.008993203637246],[-100.002189069859,50.00888246178852],[-100.00432420791059,50.008552964583245],[-100.00635281323106,50.00801282971553],[-100.00822491360869,50.007275363919106],[-100.00989439810306,50.00635873464321],[-100.01132015378204,50.005285521867904],[-100.012467078516,50.004082161177266],[-100.01330694484622,50.002778291895005],[-100.01381909370183,50.00140602642508],[-100.01399094101508,49.99999915887084],[-100.0138182849644,49.998592332484385],[-100.01330540653622,49.997220186488036],[-100.0124649612139,49.995916503290225],[-100.01131766474408,49.994713377079705],[-100.00989178097365,49.99364042422759],[-100.00822242457068,49.9927240548749],[-100.00635069592882,49.99198682355861],[-100.00432266960047,49.991446874775384],[-100.0021882611215,49.991117497043696],[-100,49.99100679636276],[-99.9978117388785,49.991117497043696],[-99.99567733039954,49.991446874775384],[-99.99364930407118,49.99198682355861],[-99.99177757542932,49.9927240548749],[-99.99010821902635,49.99364042422759],[-99.98868233525592,49.994713377079705],[-99.98753503878612,49.995916503290225],[-99.9866945934638,49.997220186488036],[-99.9861817150356,49.998592332484385],[-99.98600905898492,49.99999915887084]]]
        };
        assert.deepEqual(resultFeature, expectedFeature);
    });

    it ('ST_BUFFER should return NULL if any NULL mandatory argument', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]  
        };
        featureJSON = JSON.stringify(feature);
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_BUFFER(NULL, 1, 'kilometers', 10) as buffer1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), CAST(NULL AS FLOAT64), 'kilometers', 10) as buffer2`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].buffer1, null);
        assert.equal(rows[0].buffer2, null);
    });

    it ('ST_BUFFER default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_BUFFER(ST_GEOGPOINT(-74.00, 40.7128), 1, "kilometers", 8) as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_BUFFER(ST_GEOGPOINT(-74.00, 40.7128), 1, NULL, NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });

    it ('ST_BUFFER should fail with wrong arguments', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]  
        };
        featureJSON = JSON.stringify(feature);
    
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), -1, 'kilometers', 10);`;
        let rows;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TRANSFORMATIONS}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', -10);`;
        await assert.rejects( async () => {
            [rows] = await client.query(query, queryOptions);
        });
    });
}); /* ST_BUFFER integration tests */
