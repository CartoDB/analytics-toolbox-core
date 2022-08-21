#!/usr/bin/env node

// Build the modules file based on the input filters
// and ordered to solve the dependencies

// ./build_modules.js modules --output=build --diff=modules/quadbin/sql/QUADBIN_TOZXY.sql
// ./build_modules.js modules --output=build --functions=ST_TILEENVELOPE
// ./build_modules.js modules --output=build --modules=quadbin
// ./build_modules.js modules --output=build --production

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDir = argv._[0];
const outputDir = argv.output || 'build';
const diff = argv.diff || [];
const nodeps = argv.nodeps;
const modulesFilter = (argv.modules && argv.modules.split(',')) || [];
const functionsFilter = (argv.functions && argv.functions.split(',')) || [];
const all = !(diff.length || modulesFilter.length || functionsFilter.length);

if (all) {
    console.log('- Build all ...');
} else if (diff && diff.length) {
    console.log(`- Build input diff: ${argv.diff} ...`);
} else if (modulesFilter && modulesFilter.length) {
    console.log(`- Build input modules: ${argv.modules} ...`);
} else if (functionsFilter && functionsFilter.length) {
    console.log(`- Build input functions: ${argv.functions} ...`);
}

// Extract functions
const functions = [];
const modules = fs.readdirSync(inputDir);
modules.forEach(module => {
    const sqldir = path.join(inputDir, module, 'sql');
    if (fs.existsSync(sqldir)) {
        const files = fs.readdirSync(sqldir);
        files.forEach(file => {
            const name = path.parse(file).name;
            const content = fs.readFileSync(path.join(sqldir, file)).toString().replace(/--.*\n/g, '');
            functions.push({
                name,
                module,
                content,
                dependencies: []
            });
        });
    }
});

// Extract function dependencies
if (!nodeps) {
    functions.forEach(mainFunction => {
        functions.forEach(depFunction => {
            if (mainFunction.name != depFunction.name) {
                if (mainFunction.content.includes(`SCHEMA@@.${depFunction.name}(`)) {
                    mainFunction.dependencies.push(depFunction.name);
                }
            }
        });
    });
}

// Filter and order functions
const output = [];
function add (f, include) {
    include = include || all || diff.includes(path.join(inputDir, f.module, 'sql', f.name)) || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
    for (const dependency of f.dependencies) {
        add(functions.find(f => f.name === dependency), include);
    }
    if (!output.map(f => f.name).includes(f.name) && include) {
        output.push({
            name: f.name,
            content: f.content
        });
    }
}
functions.forEach(f => add(f));

// Replace code variables
const template = output.map(f => f.content).join('\n');
let content = '';

if (argv.production) {
    const header = fs.readFileSync(path.resolve(__dirname, 'DROP_FUNCTIONS.sql')).toString()
    const footer = fs.readFileSync(path.resolve(__dirname, 'VERSION.sql')).toString()
    const version = fs.readFileSync(path.resolve(__dirname, '..', 'version')).toString()
    content = header + template
        + footer.replace(/@@RS_VERSION_FUNCTION@@/g, process.env.RS_VERSION_FUNCTION || 'VERSION_CORE')
            .replace(/@@RS_PACKAGE_VERSION@@/g, version.replace('\r', '').replace('\n', ''));
} else {
    content = template
}

content = content
    .replace(/@@RS_SCHEMA@@/g, process.env.RS_SCHEMA || 'carto')
    .replace(/@@RS_LIBRARY@@/g, process.env.RS_LIBRARY || 'carto');

// Write modules.sql file
fs.writeFileSync(path.join(outputDir, 'modules.sql'), content);
console.log(`Write ${outputDir}/modules.sql`);