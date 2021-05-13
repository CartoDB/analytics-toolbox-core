const snowflake = require('snowflake-sdk');

const SF_DATABASE = process.env.SF_DATABASE;
const SF_SCHEMA_PREFIX = process.env.SF_SCHEMA_PREFIX;
const SF_PREFIX = `${SF_DATABASE}.${SF_SCHEMA_PREFIX}`;

let connection = snowflake.createConnection( {
    account: process.env.SNOWSQL_ACCOUNT,
    username: process.env.SNOWSQL_USER,
    password: process.env.SNOWSQL_PWD
});

connection.connect( 
    function(err) {
        if (err) {
            console.error('Unable to connect: ' + err.message);
        } 
        else 
        {
            // Optional: store the connection ID.
            //const connection_ID = conn.getId();
        }
    }
);

function execAsync(query) {
    return new Promise((resolve, reject) => {
        connection.execute({
            sqlText: query,
            complete: (err, stmt, rows) => {
                if (err) {
                    return reject(err);
                } 
                return resolve(rows);
            }
        });
    });
}

const runQuery = async (query) => {
    query = query.replace(/@@SF_PREFIX@@/g, SF_PREFIX);
    const rows = await execAsync(query);
    return rows;
}

module.exports = {
    runQuery
}
