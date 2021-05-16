#!/usr/bin/env node

// This script returns a list of the SQL files
// ordered by checking their dependencies

const fs = require('fs');
const path = require('path');

const dir = 'sql';
const input = [];
const output = [];
const ignoredFiles = ['.DS_Store'];

const files = fs.readdirSync(dir);

files.forEach(file => {
    const name = path.parse(file).name;
    if (ignoredFiles.includes(name)) {
        return;
    }
    const content = fs.readFileSync(path.join(dir, file)).toString();
    input.push({
        name,
        deps: files.map(f => path.parse(f).name).filter(n => n !== name && content.includes(n))
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