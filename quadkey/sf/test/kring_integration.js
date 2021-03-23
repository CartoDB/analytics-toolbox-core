const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_QUADKEY = process.env.SF_SCHEMA_QUADKEY;

function execAsync(connection, sqlText) {
    return new Promise((resolve, reject) => {
        connection.execute({
            sqlText: sqlText,
            complete: (err, stmt, rows) => {
                if (err) {
                    return reject(err);
                } 
                return resolve([stmt, rows]);
            }
        });
    });
}

describe('KRING integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_QUADKEY) {
            throw "Missing SF_SCHEMA_QUADKEY env variable";
        }
        connection = snowflake.createConnection( {
            account: process.env.SNOWSQL_ACCOUNT,
            username: process.env.SNOWSQL_USER,
            password: process.env.SNOWSQL_PWD
            }
        );
        connection.connect( 
            function(err, conn) {
                if (err) {
                    console.error('Unable to connect: ' + err.message);
                } 
                else 
                {
                    // Optional: store the connection ID.
                    connection_ID = conn.getId();
                }
            }
        );
    });

    it ('KRING should work', async () => {
        let query = `SELECT  ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(162,1) as kring1,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(12070922,1) as kring2,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(791040491538,1) as kring3,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(12070922,2) as kring5,
        ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(791040491538,3) as kring6,
        ARRAY_AGG(CAST(VALUE AS STRING)) as kring4 from lateral FLATTEN(input => ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(12960460429066265,NULL)) `;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].KRING1.length, 9)
        assert.deepEqual(rows[0].KRING1.sort().map(String), ['130', '162', '194',
            '2', '258', '290',
            '322', '34', '66']);
        assert.equal(rows[0].KRING2.length, 9)
        assert.deepEqual(rows[0].KRING2.sort().map(String), ['12038122', '12038154',
            '12038186', '12070890',
            '12070922', '12070954',
            '12103658', '12103690',
            '12103722']);
        assert.equal(rows[0].KRING3.length, 9)
        assert.deepEqual(rows[0].KRING3.sort().map(String), ['791032102898',
            '791032102930',
            '791032102962',
            '791040491506',
            '791040491538',
            '791040491570',
            '791048880114',
            '791048880146',
            '791048880178']);
        assert.equal(rows[0].KRING4.length, 9)
        assert.deepEqual(rows[0].KRING4.sort(), ['12960459355324409',
            '12960459355324441',
            '12960459355324473',
            '12960460429066233',
            '12960460429066265',
            '12960460429066297',
            '12960461502808057',
            '12960461502808089',
            '12960461502808121']);
        assert.equal(rows[0].KRING5.length, 25)
        assert.deepEqual(rows[0].KRING5.sort().map(String), ['12005322', '12005354', '12005386',
            '12005418', '12005450', '12038090',
            '12038122', '12038154', '12038186',
            '12038218', '12070858', '12070890',
            '12070922', '12070954', '12070986',
            '12103626', '12103658', '12103690',
            '12103722', '12103754', '12136394',
            '12136426', '12136458', '12136490',
            '12136522']);
        assert.equal(rows[0].KRING6.length, 49)
        assert.deepEqual(rows[0].KRING6.sort().map(String), ['791015325618', '791015325650', '791015325682',
            '791015325714', '791015325746', '791015325778',
            '791015325810', '791023714226', '791023714258',
            '791023714290', '791023714322', '791023714354',
            '791023714386', '791023714418', '791032102834',
            '791032102866', '791032102898', '791032102930',
            '791032102962', '791032102994', '791032103026',
            '791040491442', '791040491474', '791040491506',
            '791040491538', '791040491570', '791040491602',
            '791040491634', '791048880050', '791048880082',
            '791048880114', '791048880146', '791048880178',
            '791048880210', '791048880242', '791057268658',
            '791057268690', '791057268722', '791057268754',
            '791057268786', '791057268818', '791057268850',
            '791065657266', '791065657298', '791065657330',
            '791065657362', '791065657394', '791065657426',
            '791065657458']);
    });
    
    it ('KRING should fail with NULL argument', async () => {
        let rows;
        let query = `SELECT ${SF_DATABASEID}.${SF_SCHEMA_QUADKEY}.KRING(NULL);`;
        await assert.rejects( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
    });
}); /* KRING integration tests */
