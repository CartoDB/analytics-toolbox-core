#!/usr/bin/env node

// This script returns a list of the modules
// ordered by checking their dependencies

const fs = require('fs');
const path = require('path');

const dir = 'modules';
const cloud = process.env.CLOUD || '';
const input = [];
const output = [];

const modules = fs.readdirSync(dir);

modules.forEach(module => {
    const dirsql = path.join(dir, module, cloud, 'sql');
    if (fs.existsSync(dirsql)) {
        const files = fs.readdirSync(dirsql);
        let content = '';
        files.forEach(file => {
            content += fs.readFileSync(path.join(dir, module, cloud, 'sql', file)).toString();
        });
        input.push({
            name: module,
            deps: modules.filter(m => m !== module && content.includes(m))
        });
    }
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

process.stdout.write(output.join(' '));