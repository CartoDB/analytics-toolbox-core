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

const inputDirs = argv._[0] && argv._[0].split(',');
const outputDir = argv.output || 'build';
const libsBuildDir = argv.libs_build_dir || '../libraries/javascript/build';
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
for (let inputDir of inputDirs) {
    const sqldir = path.join(inputDir, 'sql');
    const modules = fs.readdirSync(sqldir);
    modules.forEach(module => {
        const moduledir = path.join(sqldir, module);
        if (fs.statSync(moduledir).isDirectory()) {
            const files = fs.readdirSync(moduledir);
            files.forEach(file => {
                if (file.endsWith('.sql')) {
                    const name = path.parse(file).name;
                    const content = fs.readFileSync(path.join(moduledir, file)).toString().replace(/--.*\n/g, '');
                    functions.push({
                        name,
                        module,
                        content,
                        dependencies: []
                    });
                }
            });
        }
    });
}

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

// Check circular dependencies
functions.forEach(mainFunction => {
    functions.forEach(depFunction => {
        if (mainFunction.dependencies.includes(depFunction.name) &&
            depFunction.dependencies.includes(mainFunction.name)) {
            console.log(`ERROR: Circular dependency between ${mainFunction.name} and ${depFunction.name}`);
            process.exit(1);
        }
    });
});

// Filter and order functions
const output = [];
function add (f, include) {
    include = include || all || diff.includes(path.join(f.module, f.name)) || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
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

// Replace environment variables
let separator;
if (argv.production) {
    separator = '\n';
} else {
    separator = '\n-->\n';  // marker to future SQL split
}
const template = output.map(f => f.content).join(separator);
let content = '';

function apply_replacements (text) {
    const replacements = process.env.REPLACEMENTS.split(' ');
    for (let replacement of replacements) {
        if (replacement) {
            const pattern = new RegExp(`@@${replacement}@@`, 'g');
            text = text.replace(pattern, process.env[replacement]);
        }
    }
    const libraries = [... new Set(text.match(new RegExp('@@SF_LIBRARY_.*@@', 'g')))];
    for (let library of libraries) {
        const libraryName = library.replace('@@SF_LIBRARY_', '').replace('@@', '').toLowerCase() + '.js';
        const libraryPath = path.join(libsBuildDir, libraryName);
        if (fs.existsSync(libraryPath)) {
            const libraryContent = fs.readFileSync(libraryPath).toString();
            text = text.replace(new RegExp(library, 'g'), libraryContent);
        }
        else {
            console.log(`Warning: library "${libraryName}" does not exist. Run "make build-libraries" with the same filters.`);
            process.exit(1);
        }

    }
    return text;
}

if (argv.production) {
    const header = fs.readFileSync(path.resolve(__dirname, 'DROP_FUNCTIONS.sql')).toString()
    const footer = fs.readFileSync(path.resolve(__dirname, 'VERSION.sql')).toString()
    content = header + template + apply_replacements(footer);
} else {
    content = template;
}

content = apply_replacements(content);

// Write modules.sql file
fs.writeFileSync(path.join(outputDir, 'modules.sql'), content);
console.log(`Write ${outputDir}/modules.sql`);