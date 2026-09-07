#!/usr/bin/env node

// Build the source review index for the native app package
// and check every inlined library ships a usable source map

// ./build_source_review.js modules --output=build --libs_build_dir=../libraries/javascript/build --source_maps_dir=sourcemaps

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDirs = argv._[0] && argv._[0].split(',');
const outputDir = argv.output || 'build';
const libsBuildDir = argv.libs_build_dir || '../libraries/javascript/build';
const sourceMapsDir = argv.source_maps_dir;  // no default: APP_SOURCE_MAPS_DIR is the only source of truth

if (!sourceMapsDir) {
    console.log('ERROR: --source_maps_dir is required and must match APP_SOURCE_MAPS_DIR');
    process.exit(1);
}

// Extract the functions, keeping the placeholders unresolved to identify the libraries inlined
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
                    // Strip SQL comments as build_modules.js and list_libraries.js do, so a
                    // commented-out placeholder is not recorded as an inlined library
                    const content = fs.readFileSync(path.join(moduledir, file)).toString().replace(/--.*\n/g, '');
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

// A missing or unusable map is a build failure: the package would be rejected by the security scan
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
    let map;
    try {
        map = JSON.parse(fs.readFileSync(mapPath).toString());
    } catch (e) {
        // Report it rather than dying with a raw parse error, so the build failure names the file
        errors.push(`source map "${library}.js.map" is not valid JSON: ${e.message}`);
        return;
    }
    // Every original must be recoverable from the map alone, which is what the index promises
    // the reviewer. A non-empty sourcesContent is not enough: a map with no sources at all, or
    // with null entries, recovers nothing while still satisfying a presence check.
    const sources = map.sources || [];
    const contents = map.sourcesContent || [];
    const missing = sources.filter((_, i) => typeof contents[i] !== 'string' || contents[i] === '');
    if (!sources.length) {
        errors.push(`source map "${library}.js.map" lists no sources, so no original can be recovered from it`);
    } else if (contents.length !== sources.length) {
        errors.push(`source map "${library}.js.map" has ${contents.length} sourcesContent entries for ${sources.length} sources`);
    } else if (missing.length) {
        errors.push(`source map "${library}.js.map" is missing the content of ${missing.length} of ${sources.length} sources, starting with "${missing[0]}"`);
    }
    const leaked = sources.filter(s => path.isAbsolute(s) || s.startsWith('..'));
    if (leaked.length) {
        errors.push(`source map "${library}.js.map" leaks build paths (${leaked[0]}): check sourcemapPathTransform`);
    }
});

if (errors.length) {
    errors.forEach(e => console.log(`ERROR: ${e}`));
    process.exit(1);
}

// The document, derived entirely from this build and aimed at whoever reviews the package
const functionRows = functions
    .sort((a, b) => a.name.localeCompare(b.name))
    .map(f => `| \`${f.name}\` | ${f.libraries.sort().map(l => `\`${sourceMapsDir}/${l}.js.map\``).join(', ')} |`)
    .join('\n');

const document = `# Source review

The JavaScript inlined in \`modules.sql\` is minified. Every library it inlines ships
with its source map in \`${sourceMapsDir}/\`, and each map includes \`sourcesContent\`, so
the original un-minified source can be recovered from the map on its own, with no
other file needed.

Snowflake JavaScript UDFs cannot import code: a function body has to be entirely
self-contained inside its \`CREATE FUNCTION\` statement. Each library is therefore
bundled and inlined into every function that uses it, which is why one map can cover
several functions. Every inlined copy ends with a \`//# sourceMappingURL=\` comment
naming its map, so each occurrence in \`modules.sql\` points at its own source.

## Reading a source map

A \`.map\` file is JSON. Two fields carry the original code:

- \`sources\` — the path of each original file that went into the bundle
- \`sourcesContent\` — the full text of each of those files, at the same index

So \`sourcesContent[i]\` is the complete, un-minified source of \`sources[i]\`. Browser
developer tools also load these maps directly and will display the original files.

## Which source map covers which function

| Function | Source map |
| --- | --- |
${functionRows}
`;

fs.writeFileSync(path.join(outputDir, 'SOURCE_REVIEW.md'), document);
console.log(`Write ${outputDir}/SOURCE_REVIEW.md (${libraryNames.length} libraries, ${functions.length} functions)`);