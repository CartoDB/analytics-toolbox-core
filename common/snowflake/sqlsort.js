#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const dir = 'sql';
const input = [];
const output = [];

const files = fs.readdirSync(dir);
const ignoredFiles = ['.DS_Store', '_SHARE_CREATE', '_SHARE_REMOVE'];

files.forEach(file => {
    const name = path.parse(file).name;
    if(ignoredFiles.includes(name)){
        return;
    }
    const content = fs.readFileSync(path.join(dir, file)).toString();
    input.push({
        name,
        deps: files.map(f => path.parse(f).name)
            .filter(n => n !== name && content.includes(n))
    });
});

function addf (f) {
    for (const d of f.deps) {
        addf(input.find(df => df.name === d));
    }
    if (!output.includes(f.name)) {
        output.push(f.name);
    }
}

input.forEach(addf);

process.stdout.write(output.map(o =>`sql/${o}.sql`).join(' '));
