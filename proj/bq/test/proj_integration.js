const assert = require('assert').strict;
const chaiAssert = require('chai').assert;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_PROJ = process.env.BQ_DATASET_PROJ;

describe('PROJ integration tests', () => {

    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_PROJ) {
            throw "Missing BQ_DATASET_PROJ env variable";
        }
        client = new BigQuery({projectId: `${BQ_PROJECTID}`});
    });

    it ('Returns the proper version', async () => {
        const query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROJ}\`.VERSION() as versioncol;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, 1);
    });

    it ('Proj method should work', async () => {
        let xyAcc = 2;
        const xyEPSLN = Math.pow(10, -1 * xyAcc);
        
        let query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROJ}\`.PROJ('WGS84',
        'PROJCS["NAD83 / Massachusetts Mainland",GEOGCS["NAD83",DATUM["North_American_Datum_1983",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],AUTHORITY["EPSG","6269"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4269"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["standard_parallel_1",42.68333333333333],PARAMETER["standard_parallel_2",41.71666666666667],PARAMETER["latitude_of_origin",41],PARAMETER["central_meridian",-71.5],PARAMETER["false_easting",200000],PARAMETER["false_northing",750000],AUTHORITY["EPSG","26986"],AXIS["X",EAST],AXIS["Y",NORTH]]',
        [-71.11881762742996, 42.37346263960867]) as projPoints;`;
        let rows;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        chaiAssert.closeTo(rows[0].projPoints[0], 231394.84, xyEPSLN, 'x is close');
        chaiAssert.closeTo(rows[0].projPoints[1], 902621.11, xyEPSLN, 'y is close');

        query = `SELECT \`${BQ_PROJECTID}\`.\`${BQ_DATASET_PROJ}\`.PROJ('WGS84',
        'PROJCS["World_Mollweide",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Mollweide"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",0],UNIT["Meter",1]]',
        [60.0, 60.0]) as projPoints;`;
        await assert.doesNotReject( async () => {
            const [job] = await client.createQueryJob({ query: query });
            [rows] = await job.getQueryResults();
        });
        assert.equal(rows.length, 1);
        chaiAssert.closeTo(rows[0].projPoints[0], 3891383.58309223, xyEPSLN, 'x is close');
        chaiAssert.closeTo(rows[0].projPoints[1], 6876758.9933288, xyEPSLN, 'y is close');
    });
}); /* PROJ integration tests */
