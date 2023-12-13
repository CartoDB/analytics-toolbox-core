#!/usr/bin/env node

// Build the setup_script for the native app file based on the input filters
// and ordered to solve the dependencies

// ./build_native_app_setup_script.js modules --output=build --diff="clouds/snowflake/modules/sql/quadbin/QUADBIN_TOZXY.sql"
// ./build_native_app_setup_script.js modules --output=build --functions=ST_TILEENVELOPE
// ./build_native_app_setup_script.js modules --output=build --modules=quadbin
// ./build_native_app_setup_script.js modules --output=build --production --dropfirst

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDirs = argv._[0] && argv._[0].split(',');
const outputDir = argv.output || 'build';
const libsBuildDir = argv.libs_build_dir || '../libraries/javascript/build';
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

// Convert diff to modules
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/snowflake\.yml/,
        /clouds\/snowflake\/common\/.+/,
        /clouds\/snowflake\/libraries\/.+/,
        /clouds\/snowflake\/.*Makefile/,
        /clouds\/snowflake\/version/
    ];
    const patternModulesSql = /clouds\/snowflake\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/snowflake\/modules\/test\/([^\s]*?)\//g;
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
let separator;
if (argv.production) {
    separator = '\n';
} else {
    separator = '\n-->\n';  // marker to future SQL split
}
let content = output.map(f => fetchPermissionsGrant(f.content)).join(separator);

function apply_replacements (text) {
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
    const replacements = process.env.REPLACEMENTS.split(' ');
    for (let replacement of replacements) {
        if (replacement) {
            const pattern = new RegExp(`@@${replacement}@@`, 'g');
            text = text.replace(pattern, process.env[replacement]);
        }
    }
    return text;
}

function getFunctionSignatures (functionMatches)
{
    const functSignatures = []
    for (const functionMatch of functionMatches) {
        //Remove spaces and diacritics
        let qualifiedFunctName = functionMatch[0].split('(')[0].replace(/\s+/gm,'');
        qualifiedFunctNameArr = qualifiedFunctName.split('.');
        const functName = qualifiedFunctNameArr[qualifiedFunctNameArr.length - 1];
        if (functName.startsWith('_'))
        {
            continue;
        }
        //Remove diacritics and go greedy to take the outer parentheses
        let functArgs = functionMatch[0].matchAll(new RegExp('(?<=\\()(.*)(?=\\))','g')).next().value;
        if (functArgs)
        {
            functArgs = functArgs[0];
        }
        else
        {
            continue;
        }
        functArgs = functArgs.split(',')
        let functArgsTypes = [];
        for (const functArg of functArgs) {
            const functArgSplitted = functArg.trim(' ').split(' ');
            functArgsTypes.push(functArgSplitted[functArgSplitted.length - 1]);
        }
        const functSignature = qualifiedFunctName + '(' + functArgsTypes.join(',') + ')';
        functSignatures.push(functSignature)
    }
    return functSignatures
}

function fetchPermissionsGrant (content)
{
    let fileContent = content.split('\n');
    for (let i = 0 ; i < fileContent.length; i++)
    {
        if (fileContent[i].startsWith('--'))
        {
            delete fileContent[i];
        }
    }
    fileContent = fileContent.join(' ').replace(/[\p{Diacritic}]/gu, '').replace(/\s+/gm,' ');
    const functionMatches = fileContent.matchAll(new RegExp(/(?<=(?<!TEMP )FUNCTION)(.*?)(?=RETURNS)/gs));
    const functSignatures = getFunctionSignatures(functionMatches).map(f => `GRANT USAGE ON FUNCTION ${f} TO APPLICATION ROLE @@APP_ROLE@@;`).join('\n')
    const procMatches = fileContent.matchAll(new RegExp(/(?<=PROCEDURE)(.*?)(?=AS)/gs));
    const procSignatures = getFunctionSignatures(procMatches).map(f => `GRANT USAGE ON PROCEDURE ${f} TO APPLICATION ROLE @@APP_ROLE@@;`).join('\n')
    return content + functSignatures +procSignatures
}

if (argv.dropfirst) {
    const header = fs.readFileSync(path.resolve(__dirname, 'DROP_FUNCTIONS.sql')).toString();
    content = header + separator + content
}

const header = `CREATE OR REPLACE APPLICATION ROLE @@APP_ROLE@@;
CREATE OR ALTER VERSIONED SCHEMA @@SF_SCHEMA@@;
GRANT USAGE ON SCHEMA @@SF_SCHEMA@@ TO APPLICATION ROLE @@APP_ROLE@@;\n`;

const footer = fetchPermissionsGrant (fs.readFileSync(path.resolve(__dirname, 'VERSION.sql')).toString());
content = header + separator + content + separator + footer;

content = apply_replacements(content);

// Execute as caller replacement
content = content.replace(/EXECUTE\s+AS\s+CALLER/g, 'EXECUTE AS OWNER');

// Write setup_script.sql file
fs.writeFileSync(path.join(outputDir, 'setup_script.sql'), content);
console.log(`Write ${outputDir}/setup_script.sql`);