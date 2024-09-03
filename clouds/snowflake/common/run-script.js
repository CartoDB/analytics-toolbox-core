#!/usr/bin/env node

const fs = require('fs');

const snowflake = require('snowflake-sdk');
const cliProgress = require('cli-progress');

const options = {
    barsize: 60,
    barIncompleteChar: ' ',
    format:'{percentage}%|{bar}| {value}/{total} [{duration_formatted}<{eta_formatted}]'
};
const bar = new cliProgress.SingleBar(options, cliProgress.Presets.shades_classic);

snowflake.configure({ insecureConnect: true });

const connection = snowflake.createConnection({
    account: process.env.SF_ACCOUNT,
    username: process.env.SF_USER,
    password: process.env.SF_PASSWORD,
    role: process.env.SF_ROLE,
    warehouse: process.env.SF_WAREHOUSE,
});

connection.connect((err) => {
    if (err) {
        console.error(`Unable to connect: ${err.message}`);
    }
});

async function runQuery (query) {
    return new Promise((resolve, reject) => {
        connection.execute({
            sqlText: query,
            complete: (err, stmt, rows) => {
                if (err) {
                    reject(err.message);
                } else {
                    resolve();
                }
            }
        });
    });
}

function apply_replacements (text) {
    if (process.env.REPLACEMENTS) {
        const replacements = process.env.REPLACEMENTS.split(' ');
        for (let replacement of replacements) {
            if (replacement) {
                const pattern = new RegExp(`@@${replacement}@@`, 'g');
                text = text.replace(pattern, process.env[replacement]);
            }
        }
    }
    return text;
}

async function runQueries (queries) {
    const n = queries.length;
    bar.start(n, 0);
    for (let i = 0; i < n; i++) {
        let query = apply_replacements (`BEGIN\n${queries[i]}\nEND;`);

        const pattern = /(FUNCTION|PROCEDURE)\s+(.*?)[(\n]/g;
        const results = pattern.exec(query);
        const result = results && results.reverse()[0]
        sqlFunction = result && result.split('.').reverse()[0]

        await runQuery(query);
        bar.increment();
    }
    bar.stop(n);
}

const script = process.argv[2];
let content = fs.readFileSync(script).toString();
const separator = '\n-->\n';
let sqlFunction = '';

if (process.env.SKIP_PROGRESS_BAR) {
    content = content.replaceAll(separator, '')
    runQueries([content]).catch(error => {
        console.log(`\nERROR: ${error}`);
        process.exit(1);
    });
} else {
    const queries = content.split(separator).filter(q => !!q);

    runQueries(queries).catch(error => {
        console.log(`\n[${sqlFunction}] ERROR: ${error}`);
        process.exit(1);
    });
}