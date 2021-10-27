#!/usr/bin/env node

// This script returns a list of the modules
// ordered by checking their dependencies

const fs = require('fs');
const path = require('path');

const dir = 'modules';
const cloud = process.env.CLOUD || '';
const diff = process.env.GIT_DIFF || '';
const force = process.env.INPUT_FORCE_DEPLOY || '';
const input = [];
const output = [];

let sqlFunctions = require('child_process').execSync(`CLOUD=${cloud} IGNORE="VERSION _SHARE_CREATE _SHARE_REMOVE" ASJSON=1 node ./scripts/sqlfunctions.js`).toString();
sqlFunctions = JSON.parse(sqlFunctions);

let functionPattern;
switch (cloud) {
case 'snowflake': functionPattern = (m, content) => sqlFunctions[m] && new RegExp(sqlFunctions[m].join('|')).test(content); break;
default: functionPattern = (m, content) => content.includes('@' + m); break;
}

const modules = fs.readdirSync(dir);
modules.forEach(module => {
    const sqldir = path.join(dir, module, cloud, 'sql');
    if (fs.existsSync(sqldir)) {
        const files = fs.readdirSync(sqldir);
        const content = files.map(f => fs.readFileSync(path.join(sqldir, f)).toString()).join('');
        input.push({
            name: module,
            deps: modules.filter(m => m !== module && functionPattern(m, content))
        });
    }
});

function add (i, include) {
    include = include || force === 'true' || diff === 'off' || diff.includes(path.join(dir, i.name, cloud));
    for (const dep of i.deps) {
        add(input.find(i => i.name === dep), include);
    }
    if (!output.includes(i.name) && include) {
        output.push(i.name);
    }
}

input.forEach(i => add(i));

process.stdout.write(output.join(' '));