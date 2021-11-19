#!/usr/bin/env node

// This script returns a list of the SQL files
// ordered by checking their dependencies

const fs = require('fs');
const path = require('path');

const dir = 'sql';
const input = [];
const output = [];
const cloud = process.env.CLOUD || '';
const ignoredFiles = process.env.IGNORE || '';

let functionPattern;
switch (cloud) {
case 'snowflake': functionPattern = (n) => `${n}`; break;
case 'postgres': functionPattern = (n) => `${n}`; break;
default: functionPattern = (n) => `.${n}`; break;
}

const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql'));

let sqlFunctions = {};
files.forEach(file => {
    let sqlFunctionArr = require('child_process').execSync(`CLOUD=${cloud} INPUT_FILES="${process.cwd()}/sql/${file}" IGNORE="VERSION _SHARE_CREATE _SHARE_REMOVE" INCLUDE_PRIVATE=1 DELIMITER="," node ${__dirname}/sqlfunctions.js`).toString();
    sqlFunctions[path.parse(file).name] = sqlFunctionArr.split(',');
});

files.forEach(file => {
    const name = path.parse(file).name;
    if (ignoredFiles.includes(name)) {
        return;
    }
    const content = fs.readFileSync(path.join(dir, file)).toString();
    input.push({
        name,
        deps: files.map(f => path.parse(f).name).filter(n => n !== name && sqlFunctions[n] && new RegExp(sqlFunctions[n].join('|')).test(content))
    });
});

function add (i) {
    for (const dep of i.deps) {
        add(input.find(d => d.name === dep));
    }
    if (!output.includes(i.name)) {
        output.push(i.name);
    }
}

input.forEach(add);

process.stdout.write(output.map(o =>`sql/${o}.sql`).join(' '));