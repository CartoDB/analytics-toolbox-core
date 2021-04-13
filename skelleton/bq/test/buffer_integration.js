const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_SQUELLETON = process.env.BQ_DATASET_SQUELLETON;

describe('BUFFER integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_SQUELLETON) {
            throw "Missing BQ_DATASET_SQUELLETON env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('BUFFER should work', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]
        };
        featureJSON = JSON.stringify(feature);
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SQUELLETON}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', 10) as buffer;`;
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        console.log(rows[0]);
        //let resultFeature = JSON.parse(rows[0].buffer);
        let expectedFeature = {
            buffer: Geography {
              value: 'POLYGON((-99.9860090589849 49.9999991588708, -99.9861809062982 50.0014060264251, -99.9866930551538 50.002778291895, -99.987532921484 50.0040821611773, -99.988679846218 50.0052855218679, -99.9901056018969 50.0063587346432, -99.9917750863913 50.0072753639191, -99.993647186769 50.0080128297155, -99.9956757920894 50.0085529645832, -99.997810930141 50.0088824617885, -100 50.0089932036372, -100.002189069859 50.0088824617885, -100.004324207911 50.0085529645832, -100.006352813231 50.0080128297155, -100.008224913609 50.0072753639191, -100.009894398103 50.0063587346432, -100.011320153782 50.0052855218679, -100.012467078516 50.0040821611773, -100.013306944846 50.002778291895, -100.013819093702 50.0014060264251, -100.013990941015 49.9999991588708, -100.013818284964 49.9985923324844, -100.013305406536 49.997220186488, -100.012464961214 49.9959165032902, -100.011317664744 49.9947133770797, -100.009891780974 49.9936404242276, -100.008222424571 49.9927240548749, -100.006350695929 49.9919868235586, -100.0043226696 49.9914468747754, -100.002188261122 49.9911174970437, -100 49.9910067963628, -99.9978117388785 49.9911174970437, -99.9956773303995 49.9914468747754, -99.9936493040712 49.9919868235586, -99.9917775754293 49.9927240548749, -99.9901082190264 49.9936404242276, -99.9886823352559 49.9947133770797, -99.9875350387861 49.9959165032902, -99.9866945934638 49.997220186488, -99.9861817150356 49.9985923324844, -99.9860090589849 49.9999991588708))'
            }
          };
        
        console.log(expectedFeature);
        assert.deepEqual(rows[0].buffer, expectedFeature);
    });

    it ('BUFFER should return NULL if any NULL argument', async () => {
        let feature = {
            "type": "Point",
            "coordinates": [-100, 50]  
        };
        featureJSON = JSON.stringify(feature);
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SQUELLETON}\`.ST_BUFFER(NULL, 1, 'kilometers', 10) as buffer1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SQUELLETON}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), CAST(NULL AS FLOAT64), 'kilometers', 10) as buffer2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SQUELLETON}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, NULL, 10) as buffer3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_SQUELLETON}\`.ST_BUFFER(ST_GEOGFROMGEOJSON('${featureJSON}'), 1, 'kilometers', NULL) as buffer4;`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].buffer1, null);
        assert.equal(rows[0].buffer2, null);
        assert.equal(rows[0].buffer3, null);
        assert.equal(rows[0].buffer4, null);
    });
}); /* BUFFER integration tests */
