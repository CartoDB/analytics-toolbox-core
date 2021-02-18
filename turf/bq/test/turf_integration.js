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
         //TODO: use a different type of tests for this, for instance, check that the output is equal to something else
         assert.ok(resultFeature["coordinates"][0].length > 1);
     });
    

}); /* TURF integration tests */
