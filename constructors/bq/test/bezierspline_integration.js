const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_CONSTRUCTORS = process.env.BQ_DATASET_CONSTRUCTORS;

describe('ST_BEZIERSPLINE integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_CONSTRUCTORS) {
            throw "Missing BQ_DATASET_CONSTRUCTORS env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('__BEZIERSPLINE should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.__BEZIERSPLINE(ST_ASGEOJSON(ST_GEOGFROMTEXT("LINESTRING (121.025390625 -22.91792293614603, 130.6494140625 -19.394067895396613, 138.33984375 -25.681137335685307, 138.3837890625 -32.026706293336126)")), 100, 0.85) as bezierspline1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.__BEZIERSPLINE(ST_ASGEOJSON(ST_GEOGFROMTEXT("LINESTRING (-6 -0.5,-3 0.5,0 -0.5,3 0.5, 6 -0.5,9 0.5)")), 60, 0.85) as bezierspline2`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].bezierspline1, '{"type":"LineString","coordinates":[[121.025390625,-22.917922936146],[122.49648858675529,-22.425738002318873],[124.15114875200359,-21.851911690463727],[127.02637891149514,-20.804250326767775],[129.88830572582356,-19.69855368375739],[132.273614269987,-20.7994674978615],[134.11775332597566,-22.345780567363803],[135.27860338904782,-23.29154534504447],[136.44462334377712,-24.219708257649792],[137.6392107736424,-25.14771544498035]]}');
        assert.equal(rows[0].bezierspline2, '{"type":"LineString","coordinates":[[-6,-0.5],[-3.6649305555555554,0.4259259259259258],[-1.0611111111111116,-0.24074074074074053],[1.5,0],[4.06111111111111,0.24074074074074117],[6.664930555555557,-0.42592592592592565]]}');
    });

    it ('ST_BEZIERSPLINE should return NULL if any NULL mandatory argument', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_BEZIERSPLINE(NULL, 10000, 0.9) as bezierspline1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].bezierspline1, null);
    });

    it ('ST_BEZIERSPLINE default values should work', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_BEZIERSPLINE(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 10000, 0.85) as defaultValue,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_BEZIERSPLINE(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), NULL, NULL) as nullParam1`;
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.deepEqual(rows[0].nullParam1, rows[0].defaultValue);
    });
}); /* ST_BEZIERSPLINE integration tests */
