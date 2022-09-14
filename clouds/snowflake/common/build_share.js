#!/usr/bin/env node

// Build the modules file based on the input filters
// and ordered to solve the dependencies

// ./build_share.js modules --output=build --diff=modules/quadbin/sql/QUADBIN_TOZXY.sql
// ./build_share.js modules --output=build --functions=ST_TILEENVELOPE
// ./build_share.js modules --output=build --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDirs = argv._[0] && argv._[0].split(',');
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
if (!nodeps) {
    functions.forEach(mainFunction => {
        functions.forEach(depFunction => {
            if (mainFunction.dependencies.includes(depFunction.name) &&
                depFunction.dependencies.includes(mainFunction.name)) {
                console.log(`ERROR: Circular dependency between ${mainFunction.name} and ${depFunction.name}`);
                process.exit(1);
            }
        });
    });
}

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

const template = output.map(f => f.content).join('\n');

//Extract functions declaration
const udfs = [];
//For the moment procedures cannot be shared
const functionMatches = template.replace(/(\r\n|\n|\r)/gm,' ').matchAll(new RegExp('(?<=(?<!TEMP )SECURE FUNCTION)(.*?)(?=RETURNS)','g'));
for (const functionMatch of functionMatches) {
    //Remove spaces and diacritics
    let qualifiedFunctName = functionMatch[0].replace(/[ \p{Diacritic}]/gu, '').split('(')[0];
    const functName = qualifiedFunctName;
    let functArgs = functionMatch[0].replace(/[\p{Diacritic}]/gu, '').matchAll(new RegExp('(?<=\\()(.*)(?=\\))','g')).next().value;
    if (functArgs)
    {
        functArgs = functArgs[0];
    }
    else
    {
        continue;
    }
    //This does not work with BigQuery ARRAY/STRUCT
    functArgs = functArgs.split(',')
    let functArgsTypes = [];
    for (const functArg of functArgs) {
        const functArgSplitted = functArg.split(' ');
        functArgsTypes.push(functArgSplitted[functArgSplitted.length - 1]);
    }
    const functSignature = functName + '(' + functArgsTypes.join(',') + ')';
    udfs.push(functSignature)
}

let content = '';
udfs.forEach(udf => content += `GRANT USAGE ON FUNCTION ${udf} TO SHARE @@SF_SHARE@@;\n`);

// Replace environment variables
function apply_replacements (text) {
    const replacements = process.env.REPLACEMENTS.split(' ');
    for (let replacement of replacements) {
        if (replacement) {
            const pattern = new RegExp(`@@${replacement}@@`, 'g');
            text = text.replace(pattern, process.env[replacement]);
        }
    }
    return text;
}

content = apply_replacements(content);

// Write share.sql file
fs.writeFileSync(path.join(outputDir, 'share.sql'), content);
console.log(`Write ${outputDir}/share.sql`);