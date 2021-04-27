const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_CONSTRUCTORS = process.env.BQ_DATASET_CONSTRUCTORS;

describe('MAKEENVELOPE integration tests', () => {
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

    it ('MAKEENVELOPE should work', async () => {

        let xmin = 10.0;
        let ymin = 10.0;
        let xmax = 11.0;
        let ymax = 11.0;
    
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(${xmin},${ymin},${xmax},${ymax}) as poly;`;
        let rows;
        
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        let resultFeature = rows[0].poly.value;
        let expectedPolygon = 'POLYGON((10 10, 10 11, 11 11, 11 10, 10 10))';

        assert.deepEqual(resultFeature, expectedPolygon);
    });

    it ('MAKEENVELOPE should return NULL if any NULL argument', async () => {

        let xmin = 10.0;
        let ymin = 10.0;
        let xmax = 11.0;
        let ymax = 11.0;

        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(NULL,${ymin},${xmax},${ymax}) as poly1,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(${xmin},NULL,${xmax},${ymax}) as poly2,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(${xmin},${ymin},NULL,${ymax}) as poly3,
        \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(${xmin},${ymin},${xmax},NULL) as poly4;`
        
        let rows;
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].poly1, null);
        assert.equal(rows[0].poly2, null);
        assert.equal(rows[0].poly3, null);
        assert.equal(rows[0].poly4, null);
    });

    it ('MAKEENVELOPE should be robust to data input', async () => {

        let xmin = -10.0;
        let ymin = -10.0;
        let xmax = 10.0;
        let ymax = 10.0;
    
        const query1 = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(${xmin},${ymin},${xmax},${ymax}) as poly1;`;
        const query2 = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_CONSTRUCTORS}\`.ST_MAKEENVELOPE(${xmax},${ymax},${xmin},${ymin}) as poly2;`;
        let expectedPolygon = 'POLYGON((-10 -10, -10 10, 10 10, 10 -10, -10 -10))';
        let rows;
        
        await assert.doesNotReject( async () => {
            [rows] = await client.query(query1, queryOptions);
        });
        assert.equal(rows.length, 1);
        let resultFeature1 = rows[0].poly1.value;

        await assert.doesNotReject( async () => {
            [rows] = await client.query(query2, queryOptions);
        });
        assert.equal(rows.length, 1);

        let resultFeature2 = rows[0].poly2.value;

        assert.deepEqual(resultFeature1, expectedPolygon);
        assert.deepEqual(resultFeature2, expectedPolygon);
    });

}); /* MAKEENVELOPE integration tests */
