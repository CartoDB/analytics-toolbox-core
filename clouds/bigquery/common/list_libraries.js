#!/usr/bin/env node

// List the JavaScript libraries based on the input filters to the SQL functions


// ./build_modules.js modules --output=build --diff="clouds/bigquery/modules/sql/quadbin/QUADBIN_TOZXY.sql"
// ./build_modules.js modules --output=build --functions=ST_TILEENVELOPE
// ./build_modules.js modules --output=build --modules=quadbin
// ./build_modules.js modules --output=build --production --dropfirst

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDirs = argv._[0] && argv._[0].split(',');
const diff = argv.diff || [];
const nodeps = argv.nodeps;
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Convert diff to modules/functions
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/bigquery\.yml/,
        /clouds\/bigquery\/common\/.+/,
        /clouds\/bigquery\/libraries\/.+/,
        /clouds\/bigquery\/.*Makefile/,
        /clouds\/bigquery\/version/
    ];
    const patternModulesSql = /clouds\/bigquery\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/bigquery\/modules\/test\/([^\s]*?)\//g;
    const diffAll = patternsAll.some(p => diff.match(p));
    if (diffAll) {
        all = diffAll;
    } else {
        const modulesSql = [...diff.matchAll(patternModulesSql)].map(m => m[1]);
        const modulesTest = [...diff.matchAll(patternModulesTest)].map(m => m[1]);
        const diffModulesFilter = [...new Set(modulesSql.concat(modulesTest))];
        if (diffModulesFilter) {
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
        process.stderr.write(`ERROR: Module not found ${m}\n`);
        process.exit(1);
    }
});
functionsFilter.forEach(f => {
    if (!functions.map(fn => fn.name).includes(f)) {
        process.stderr.write(`ERROR: Function not found ${f}`);
        process.exit(1);
    }
});

// Extract function dependencies
if (!nodeps) {
    functions.forEach(mainFunction => {
        functions.forEach(depFunction => {
            if (mainFunction.name != depFunction.name) {
                const depFunctionMatches = [];
                depFunctionMatches.push(...depFunction.content.replace(/(\r\n|\n|\r)/gm,' ').matchAll(new RegExp('(?<=(?<!TEMP )FUNCTION)(.*?)(?=AS |RETURNS)','g')));
                depFunctionMatches.push(...depFunction.content.replace(/(\r\n|\n|\r)/gm,' ').matchAll(new RegExp('(?<=PROCEDURE)(.*?)(?=BEGIN)','g')));
                const depFunctionNames = [];
                depFunctionMatches.forEach((depFunctionMatch) => {
                    let qualifiedDepFunctName = depFunctionMatch[0].replace(/[ \p{Diacritic}]/gu, '').split('(')[0];
                    qualifiedDepFunctName = qualifiedDepFunctName.split('.');
                    depFunctionNames.push(qualifiedDepFunctName[qualifiedDepFunctName.length - 1]);
                })
                if (depFunctionNames.some((depFunctionName) => mainFunction.content.includes(`DATASET@@.${depFunctionName}\`(`))) {
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
            process.stderr.write(`ERROR: Circular dependency between ${mainFunction.name} and ${depFunction.name}`);
            process.exit(1);
        }
    });
});


// Filter functions
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

const content = output.map(f => f.content).join('\n');
const libraries = [... new Set(content.match(new RegExp('@@BQ_LIBRARY_.*_BUCKET@@', 'g')))]
    .map(l => l.replace('@@BQ_LIBRARY_', '').replace('_BUCKET@@', '').toLowerCase());

process.stdout.write(libraries.join(' '));