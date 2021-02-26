const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_TURF = process.env.BQ_DATASET_TURF;

describe('TURF integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_TURF) {
            throw "Missing BQ_DATASET_TURF env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TURF}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('BBOX should work', async () => {
        let feature = {
            "type": "Feature",
            "geometry": { "type": "LineString", "coordinates": [[-10, -40], [10, 45]]}
        };
        featureJSON = JSON.stringify(feature);
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TURF}\`.BBOX(@geojson) as bbox;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query,
                params: {geojson: featureJSON}});
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].bbox, [-10, -40, 10, 45]);
    });

    it ('SIMPLIFY should work', async () => {
       let feature = {
            "type": "Feature",
            "geometry": 
              {
                "type": "LineString",
                "coordinates": [
                  [27.977542877197266, -26.17500493262446],
                  [27.975482940673828, -26.17870225771557],
                  [27.969818115234375, -26.177931991326645],
                  [27.967071533203125, -26.177623883345735],
                  [27.966899871826172, -26.1810130263384],
                  [27.967758178710938, -26.1853263385099],
                  [27.97290802001953, -26.1853263385099],
                  [27.97496795654297, -26.18270756087535],
                  [27.97840118408203, -26.1810130263384],
                  [27.98011779785156, -26.183323749143113],
                  [27.98011779785156, -26.18655868408986],
                  [27.978744506835938, -26.18933141398614],
                  [27.97496795654297, -26.19025564262006],
                  [27.97119140625, -26.19040968001282],
                  [27.969303131103516, -26.1899475672235],
                  [27.96741485595703, -26.189639491012183],
                  [27.9656982421875, -26.187945057286793],
                  [27.965354919433594, -26.18563442612686],
                  [27.96432495117187, -26.183015655416536]
                ]
            }
        };
        featureJSON = JSON.stringify(feature);
      
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TURF}\`.SIMPLIFY(@geojson, STRUCT(0.01 as tolerance, false as highQuality)) as simplified;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query,
                params: {geojson: featureJSON},
                });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        let resultFeature = JSON.parse(rows[0].simplified);
        assert.ok(resultFeature["geometry"]["coordinates"].length < feature["geometry"]["coordinates"].length);
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
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_TURF}\`.BUFFER(@geojson, 1, STRUCT('kilometers', 10)) as buffer;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query,
                params: {geojson: featureJSON},
                });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        let resultFeature = JSON.parse(rows[0].buffer);
        let expectedFeature = {
        "type":"Polygon",
            "coordinates":[[[-99.98600905898492,49.99999915887084],[-99.98618090629817,50.00140602642508],[-99.9866930551538,50.002778291895005],[-99.987532921484,50.004082161177266],[-99.98867984621796,50.005285521867904],[-99.99010560189694,50.00635873464321],[-99.99177508639131,50.007275363919106],[-99.99364718676895,50.00801282971553],[-99.99567579208941,50.008552964583245],[-99.997810930141,50.00888246178852],[-100,50.008993203637246],[-100.002189069859,50.00888246178852],[-100.00432420791059,50.008552964583245],[-100.00635281323106,50.00801282971553],[-100.00822491360869,50.007275363919106],[-100.00989439810306,50.00635873464321],[-100.01132015378204,50.005285521867904],[-100.012467078516,50.004082161177266],[-100.01330694484622,50.002778291895005],[-100.01381909370183,50.00140602642508],[-100.01399094101508,49.99999915887084],[-100.0138182849644,49.998592332484385],[-100.01330540653622,49.997220186488036],[-100.0124649612139,49.995916503290225],[-100.01131766474408,49.994713377079705],[-100.00989178097365,49.99364042422759],[-100.00822242457068,49.9927240548749],[-100.00635069592882,49.99198682355861],[-100.00432266960047,49.991446874775384],[-100.0021882611215,49.991117497043696],[-100,49.99100679636276],[-99.9978117388785,49.991117497043696],[-99.99567733039954,49.991446874775384],[-99.99364930407118,49.99198682355861],[-99.99177757542932,49.9927240548749],[-99.99010821902635,49.99364042422759],[-99.98868233525592,49.994713377079705],[-99.98753503878612,49.995916503290225],[-99.9866945934638,49.997220186488036],[-99.9861817150356,49.998592332484385],[-99.98600905898492,49.99999915887084]]]
        };
        assert.deepEqual(resultFeature, expectedFeature);
    });
}); /* TURF integration tests */
