#!/usr/bin/env node

// Build the modules file based on the input filters
// and ordered to solve the dependencies

// ./build_modules.js modules --output=build --diff="clouds/databricks/modules/sql/quadbin/QUADBIN_TOZXY.sql"
// ./build_modules.js modules --output=build --functions=ST_TILEENVELOPE
// ./build_modules.js modules --output=build --modules=quadbin
// ./build_modules.js modules --output=build --production --dropfirst

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDirs = argv._[0] && argv._[0].split(',');
const outputDir = argv.output || 'build';
const diff = argv.diff || [];
const nodeps = argv.nodeps;
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

if (all) {
    console.log('- Build all');
} else if (diff && diff.length) {
    console.log(`- Build input diff: ${argv.diff}`);
} else if (modulesFilter && modulesFilter.length) {
    console.log(`- Build input modules: ${argv.modules}`);
} else if (functionsFilter && functionsFilter.length) {
    console.log(`- Build input functions: ${argv.functions}`);
}

// Convert diff to modules/functions
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/databricks\.yml/,
        /clouds\/databricks\/common\/.+/,
        /clouds\/databricks\/libraries\/.+/,
        /clouds\/databricks\/.*Makefile/,
        /clouds\/databricks\/version/
    ];
    const patternModulesSql = /clouds\/databricks\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/databricks\/modules\/test\/([^\s]*?)\//g;
    const diffAll = patternsAll.some(p => diff.match(p));
    if (diffAll) {
        console.log('-- all');
        all = diffAll;
    } else {
        const modulesSql = [...diff.matchAll(patternModulesSql)].map(m => m[1]);
        const modulesTest = [...diff.matchAll(patternModulesTest)].map(m => m[1]);
        const diffModulesFilter = [...new Set(modulesSql.concat(modulesTest))];
        if (diffModulesFilter) {
            console.log(`-- modules: ${diffModulesFilter}`);
            modulesFilter = diffModulesFilter;
        }
    }
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

// Check filters
modulesFilter.forEach(m => {
    if (!functions.map(fn => fn.module).includes(m)) {
        console.log(`ERROR: Module not found ${m}`);
        process.exit(1);
    }
});
functionsFilter.forEach(f => {
    if (!functions.map(fn => fn.name).includes(f)) {
        console.log(`ERROR: Function not found ${f}`);
        process.exit(1);
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
    include = include || all || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
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
let content = output.map(f => f.content).join('\n');

function apply_replacements (text) {
    const replacements = process.env.REPLACEMENTS.split(' ');
    for (let replacement of replacements) {
        if (replacement) {
            const pattern = new RegExp(`@@${replacement}@@`, 'g');
            text = text.replace(pattern, process.env[replacement]);
        }
    }
    text = text.replace(/\\\`/g, '\`');
    return text;
}

if (argv.dropfirst) {
    const header = fs.readFileSync(path.resolve(__dirname, 'DROP_FUNCTIONS.sql')).toString();
    content = header + content;
}

const footer = fs.readFileSync(path.resolve(__dirname, 'VERSION.sql')).toString();
content += footer;

content = apply_replacements(content);

// Write modules.sql file
fs.writeFileSync(path.join(outputDir, 'modules.sql'), content);
console.log(`Write ${outputDir}/modules.sql`);
