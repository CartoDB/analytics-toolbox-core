#!/usr/bin/env node

// Build the modules file based on the input filters
// and ordered to solve the dependencies

// ./build_modules.js modules --output=build --diff="clouds/oracle/modules/sql/test/ADD_ONE.sql"
// ./build_modules.js modules --output=build --functions=ADD_ONE
// ./build_modules.js modules --output=build --modules=test
// ./build_modules.js modules --output=build --dropfirst

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
        /\.github\/workflows\/oracle\.yml/,
        /clouds\/oracle\/common\/.+/,
        /clouds\/oracle\/libraries\/.+/,
        /clouds\/oracle\/.*Makefile/,
        /clouds\/oracle\/version/
    ];
    const patternModulesSql = /clouds\/oracle\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/oracle\/modules\/test\/([^\s]*?)\//g;
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
    if (!fs.existsSync(sqldir)) {
        continue;
    }
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

// Extract function and type dependencies
//
// Three reference patterns are detected:
//   1. Function calls:    @@SCHEMA@@.NAME(   — paren-suffixed
//   2. MLE module refs:   AS MLE MODULE NAME — keyword-prefixed
//   3. Type references:   @@SCHEMA@@.NAME    — bare (no paren)
//
// For (3), we collect the names of types/modules each file *defines* by
// scanning for CREATE TYPE / CREATE OR REPLACE MLE MODULE, then mark a
// dependency when another file references one of those names. Files that
// only define types (e.g. _types.sql) end up topologically before any
// function that uses them, with no filename convention required.
if (!nodeps) {
    // Map: object name → file that defines it
    const definedBy = {};
    functions.forEach(f => {
        // Function definitions: filename = name (existing convention)
        definedBy[f.name.toUpperCase()] = f.name;
        // CREATE [OR REPLACE] TYPE @@SCHEMA@@.NAME
        const typeMatches = f.content.matchAll(
            /CREATE\s+(?:OR\s+REPLACE\s+)?TYPE\s+@@\w+@@\.(\w+)/gi
        );
        for (const m of typeMatches) {
            definedBy[m[1].toUpperCase()] = f.name;
        }
        // CREATE OR REPLACE MLE MODULE [@@SCHEMA@@.]NAME
        const mleMatches = f.content.matchAll(
            /CREATE\s+(?:OR\s+REPLACE\s+)?MLE\s+MODULE\s+(?:@@\w+@@\.)?(\w+)/gi
        );
        for (const m of mleMatches) {
            definedBy[m[1].toUpperCase()] = f.name;
        }
    });

    functions.forEach(mainFunction => {
        Object.keys(definedBy).forEach(name => {
            const definerName = definedBy[name];
            if (mainFunction.name === definerName) return;
            const content = mainFunction.content;
            // (1) function call:  @@SCHEMA@@.NAME(
            const isFunctionCall = content.includes(`SCHEMA@@.${name}(`);
            // (2) MLE module ref:  AS MLE MODULE [@@SCHEMA@@.]NAME
            const mleRef = new RegExp(
                `\\bAS\\s+MLE\\s+MODULE\\s+(?:@@\\w+@@\\.)?${name}\\b`, 'i'
            );
            const isMleRef = mleRef.test(content);
            // (3) bare type ref:   @@SCHEMA@@.NAME (not followed by '(' or word char)
            const typeRef = new RegExp(
                `@@\\w+@@\\.${name}(?![\\w(])`, 'i'
            );
            const isTypeRef = typeRef.test(content);

            if (isFunctionCall || isMleRef || isTypeRef) {
                if (!mainFunction.dependencies.includes(definerName)) {
                    mainFunction.dependencies.push(definerName);
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

// Inline @@ORA_LIBRARY_<NAME>@@ → libraries/javascript/build/<name>.js, then
// apply env-var @@VAR@@ replacements.
function apply_replacements (text) {
    const libraryDir = path.resolve(
        __dirname, '..', 'libraries', 'javascript', 'build'
    );
    const libraries = [...new Set(text.match(/@@ORA_LIBRARY_[A-Z0-9_]+@@/g) || [])];
    for (const library of libraries) {
        const libName = library.replace('@@ORA_LIBRARY_', '').replace('@@', '');
        const file = path.join(libraryDir, libName.toLowerCase() + '.js');
        if (!fs.existsSync(file)) {
            console.error(
                `Error: library bundle "${file}" not found. Run \`make build\` ` +
                'in libraries/javascript/ to produce it before deploying.'
            );
            process.exit(1);
        }
        text = text.replace(
            new RegExp(library, 'g'),
            fs.readFileSync(file).toString()
        );
    }
    const replacements = process.env.REPLACEMENTS.split(' ');
    for (const replacement of replacements) {
        if (replacement) {
            const pattern = new RegExp(`@@${replacement}@@`, 'g');
            text = text.replace(pattern, process.env[replacement]);
        }
    }
    return text;
}

if (argv.dropfirst) {
    const header = fs.readFileSync(path.resolve(__dirname, 'INTERNAL_DROP_FUNCTIONS.sql')).toString();
    content = header + content;
}

// Add GRANT_ACCESS helper procedure (before VERSION)
const grantAccess = fs.readFileSync(path.resolve(__dirname, 'GRANT_ACCESS.sql')).toString().replace(/--.*\n/g, '');
content += grantAccess;

const footer = fs.readFileSync(path.resolve(__dirname, 'VERSION.sql')).toString().replace(/--.*\n/g, '');
content += footer;

content = apply_replacements(content);

// Write modules.sql file
fs.writeFileSync(path.join(outputDir, 'modules.sql'), content);
console.log(`Write ${outputDir}/modules.sql`);