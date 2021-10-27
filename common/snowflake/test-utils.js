const snowflake = require('snowflake-sdk');

const connection = snowflake.createConnection( {
    account: process.env.SNOWSQL_ACCOUNT,
    username: process.env.SNOWSQL_USER,
    password: process.env.SNOWSQL_PWD,
    database: process.env.SF_DATABASE,
    schema: process.env.SF_SCHEMA
});

connection.connect((err) => {
    if (err) {
        console.error(`Unable to connect: ${err.message}`);
    } else {
        // Optional: store the connection ID.
        //const connection_ID = conn.getId();
    }
});

function execAsync (query) {
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

async function runQuery (query) {
    const rows = await execAsync(query);
    return rows;
}

function sortByKey (list, key) {
    return list.sort((a, b) => (a[key] > b[key]) ? 1 : -1);
}

module.exports = {
    runQuery,
    sortByKey
}