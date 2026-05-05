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

// Convert diff to modules
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

// Extract functions. Files like _types.sql and _module.sql are intentionally
// reused across modules (per the typing convention), so each file is
// keyed by "module/name" internally to disambiguate.
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

const fnKey = f => `${f.module}/${f.name}`;
const byKey = {};
functions.forEach(f => { byKey[fnKey(f)] = f; });

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

// Module-shared files (_types.sql, _module.sql): types and MLE modules
// are module-scoped and module-private by convention. Any non-shared
// file in module M synthetically depends on M's shared files, so the
// topological sort guarantees they're emitted first within the module.
const isShared = f => f.name.startsWith('_');
functions.forEach(f => {
    if (isShared(f)) return;
    functions.forEach(s => {
        if (!isShared(s) || s.module !== f.module) return;
        if (!f.dependencies.includes(fnKey(s))) {
            f.dependencies.push(fnKey(s));
        }
    });
});

// Extract function-call dependencies. Mirrors the algorithm used by
// every other cloud: a file referencing @@SCHEMA@@.NAME( depends on
// the file named NAME in that file's module (or any module — function
// names are unique across modules).
if (!nodeps) {
    functions.forEach(mainFunction => {
        functions.forEach(depFunction => {
            if (isShared(depFunction)) return;
            if (fnKey(mainFunction) === fnKey(depFunction)) return;
            if (mainFunction.content.includes(`SCHEMA@@.${depFunction.name}(`)) {
                if (!mainFunction.dependencies.includes(fnKey(depFunction))) {
                    mainFunction.dependencies.push(fnKey(depFunction));
                }
            }
        });
    });
}

// Check circular dependencies
if (!nodeps) {
    functions.forEach(mainFunction => {
        for (const depKey of mainFunction.dependencies) {
            const depFunction = byKey[depKey];
            if (depFunction && depFunction.dependencies.includes(fnKey(mainFunction))) {
                console.log(`ERROR: Circular dependency between ${fnKey(mainFunction)} and ${depKey}`);
                process.exit(1);
            }
        }
    });
}

// Filter and order functions
const output = [];
const seen = new Set();
function add (f, include) {
    include = include || all || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
    for (const dependencyKey of f.dependencies) {
        const dep = byKey[dependencyKey];
        if (dep) add(dep, include);
    }
    const key = fnKey(f);
    if (!seen.has(key) && include) {
        seen.add(key);
        output.push({
            module: f.module,
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
