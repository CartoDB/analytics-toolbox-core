#!/usr/bin/env node

// Build the source review index for the native app package and verify that
// every JavaScript library inlined into modules.sql ships a source map.
//
// Snowflake's Native App security scan requires all app code to be
// un-obfuscated. Minified JavaScript is allowed only when the package includes
// a corresponding source map that recovers the un-minified code, so this script
// both documents the correspondence for the reviewer and fails the build when a
// map is missing.

// ./build_source_review.js modules --output=build --libs_build_dir=../libraries/javascript/build

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDirs = argv._[0] && argv._[0].split(',');
const outputDir = argv.output || 'build';
const libsBuildDir = argv.libs_build_dir || '../libraries/javascript/build';
const sourceMapsDir = argv.source_maps_dir || 'source_review';

// Extract the functions, keeping the placeholders unresolved so the libraries
// each function inlines can be identified (build_modules.js resolves them).
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
                    const content = fs.readFileSync(path.join(moduledir, file)).toString();
                    const libraries = [... new Set(content.match(/@@SF_LIBRARY_[A-Z0-9_]+@@/g) || [])]
                        .map(l => l.replace('@@SF_LIBRARY_', '').replace('@@', '').toLowerCase());
                    if (libraries.length && !functions.some(f => f.name === name)) {
                        functions.push({ name, module, libraries });
                    }
                }
            });
        }
    });
}

// Invert into library -> functions
const libraries = {};
functions.forEach(f => {
    f.libraries.forEach(library => {
        libraries[library] = libraries[library] || [];
        libraries[library].push(f.name);
    });
});

// Check that every library inlined into the SQL ships a source map the
// un-minified code can actually be recovered from. A missing or unusable map is
// a build failure: the package would be rejected by the security scan.
const errors = [];
const libraryNames = Object.keys(libraries).sort();
libraryNames.forEach(library => {
    const bundlePath = path.join(libsBuildDir, `${library}.js`);
    const mapPath = `${bundlePath}.map`;
    if (!fs.existsSync(bundlePath)) {
        errors.push(`library "${library}" is inlined by ${libraries[library].join(', ')} but ${bundlePath} does not exist`);
        return;
    }
    if (!fs.readFileSync(bundlePath).toString().includes('//# sourceMappingURL=')) {
        errors.push(`bundle "${library}.js" has no sourceMappingURL comment: enable "sourcemap" in the rollup config`);
    }
    if (!fs.existsSync(mapPath)) {
        errors.push(`library "${library}" has no source map at ${mapPath}`);
        return;
    }
    const map = JSON.parse(fs.readFileSync(mapPath).toString());
    if (!map.sourcesContent || !map.sourcesContent.length) {
        errors.push(`source map "${library}.js.map" has no sourcesContent, so the un-minified code cannot be recovered from it`);
    }
    const leaked = (map.sources || []).filter(s => path.isAbsolute(s) || s.startsWith('..'));
    if (leaked.length) {
        errors.push(`source map "${library}.js.map" leaks build paths (${leaked[0]}): check sourcemapPathTransform`);
    }
});

if (errors.length) {
    errors.forEach(e => console.log(`ERROR: ${e}`));
    process.exit(1);
}

// The document. Everything in it is derived from this build: no content is
// maintained by hand, and it is aimed at whoever reviews the package, so it
// carries only what is needed to get from minified code to its source.
const lines = [];
lines.push('# Source review');
lines.push('');
lines.push('The JavaScript inlined in `modules.sql` is minified. Every library it inlines ships');
lines.push('with its source map in `' + sourceMapsDir + '/`, and each map includes `sourcesContent`, so the');
lines.push('original un-minified source can be recovered from the map on its own, with no other');
lines.push('file needed.');
lines.push('');
lines.push('Snowflake JavaScript UDFs cannot import code: a function body has to be entirely');
lines.push('self-contained inside its `CREATE FUNCTION` statement. Each library is therefore');
lines.push('bundled and inlined into every function that uses it, which is why one map can cover');
lines.push('several functions. Every inlined copy ends with a `//# sourceMappingURL=` comment');
lines.push('naming its map, so each occurrence in `modules.sql` points at its own source.');
lines.push('');
lines.push('## Reading a source map');
lines.push('');
lines.push('A `.map` file is JSON. Two fields carry the original code:');
lines.push('');
lines.push('- `sources` — the path of each original file that went into the bundle');
lines.push('- `sourcesContent` — the full text of each of those files, at the same index');
lines.push('');
lines.push('So `sourcesContent[i]` is the complete, un-minified source of `sources[i]`. Browser');
lines.push('developer tools also load these maps directly and will display the original files.');
lines.push('');
lines.push('## Which source map covers which function');
lines.push('');
lines.push('| Function | Source map |');
lines.push('| --- | --- |');
functions.sort((a, b) => a.name.localeCompare(b.name)).forEach(f => {
    const maps = f.libraries.sort().map(l => `\`${sourceMapsDir}/${l}.js.map\``).join(', ');
    lines.push(`| \`${f.name}\` | ${maps} |`);
});
lines.push('');
fs.writeFileSync(path.join(outputDir, 'SOURCE_REVIEW.md'), lines.join('\n'));
console.log(`Write ${outputDir}/SOURCE_REVIEW.md (${libraryNames.length} libraries, ${functions.length} functions)`);