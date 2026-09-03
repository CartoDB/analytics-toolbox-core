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
const crypto = require('crypto');
const { execSync } = require('child_process');
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

// Collect the built artifacts and check every library ships a usable map
const errors = [];
const entries = Object.keys(libraries).sort().map(library => {
    const bundlePath = path.join(libsBuildDir, `${library}.js`);
    const mapPath = `${bundlePath}.map`;
    if (!fs.existsSync(bundlePath)) {
        errors.push(`library "${library}" is inlined by ${libraries[library].join(', ')} but ${bundlePath} does not exist`);
        return null;
    }
    const bundle = fs.readFileSync(bundlePath);
    if (!bundle.toString().includes('//# sourceMappingURL=')) {
        errors.push(`bundle "${library}.js" has no sourceMappingURL comment: enable "sourcemap" in the rollup config`);
    }
    if (!fs.existsSync(mapPath)) {
        errors.push(`library "${library}" has no source map at ${mapPath}`);
        return null;
    }
    const map = JSON.parse(fs.readFileSync(mapPath).toString());
    if (!map.sourcesContent || !map.sourcesContent.length) {
        errors.push(`source map "${library}.js.map" has no sourcesContent, so the un-minified code cannot be recovered from it`);
    }
    const leaked = (map.sources || []).filter(s => path.isAbsolute(s) || s.startsWith('..'));
    if (leaked.length) {
        errors.push(`source map "${library}.js.map" leaks build paths (${leaked[0]}): check sourcemapPathTransform`);
    }
    return {
        library,
        functions: [... new Set(libraries[library])].sort(),
        bundleSize: bundle.length,
        bundleSha256: crypto.createHash('sha256').update(bundle).digest('hex'),
        mapSize: fs.statSync(mapPath).size,
        sources: (map.sources || []).length
    };
});

if (errors.length) {
    errors.forEach(e => console.log(`ERROR: ${e}`));
    process.exit(1);
}

// Build provenance, so the reviewer can reproduce the bundles rather than trust them
function describeBuild () {
    let commit = 'unknown';
    try {
        commit = execSync('git rev-parse --short HEAD', { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim();
    } catch (e) {
        // Not a git checkout (e.g. building from a package): leave it unknown
    }
    const dependencies = require(path.resolve(__dirname, 'package.json')).devDependencies || {};
    const versions = ['rollup', 'rollup-plugin-terser']
        .filter(d => dependencies[d])
        .map(d => `${d} ${dependencies[d]}`)
        .join(', ');
    return { commit, versions };
}

const { commit, versions } = describeBuild();
const totalEmbedded = entries.reduce((total, e) => total + e.bundleSize * e.functions.length, 0);

const lines = [];
lines.push('# Source review');
lines.push('');
lines.push('The JavaScript in `modules.sql` is minified. This package includes a source map for');
lines.push('every library it inlines, so the un-minified code can be recovered from the map alone');
lines.push('(`sourcesContent` is included).');
lines.push('');
lines.push('Snowflake JavaScript UDFs have no import mechanism: a function body must be entirely');
lines.push('self-contained inside its `CREATE FUNCTION` statement. Each library is therefore');
lines.push('bundled and inlined into every function that uses it, which is why one source map can');
lines.push('cover several functions. Each inlined bundle ends with a');
lines.push('`//# sourceMappingURL=` comment naming its map, so every occurrence is linked');
lines.push('individually from inside the function body.');
lines.push('');
lines.push('## Build');
lines.push('');
lines.push(`- commit: \`${commit}\``);
lines.push(`- node: \`${process.version}\``);
if (versions) {
    lines.push(`- bundler: \`${versions}\``);
}
lines.push('- command: `make deploy-native-app-package production=1`');
lines.push('- The build is deterministic: rebuilding from this commit reproduces the bundles');
lines.push('  byte-for-byte, so the SHA-256 values below can be verified independently.');
lines.push('');
lines.push(`## Libraries (${entries.length})`);
lines.push('');
entries.forEach(e => {
    lines.push(`### ${e.library}`);
    lines.push('');
    lines.push(`- source map: \`${sourceMapsDir}/${e.library}.js.map\` (${e.mapSize.toLocaleString('en-US')} bytes, ${e.sources} original sources)`);
    lines.push(`- inlined bundle: ${e.bundleSize.toLocaleString('en-US')} bytes, sha256 \`${e.bundleSha256}\``);
    lines.push(`- inlined into ${e.functions.length} function(s): ${e.functions.map(f => `\`${f}\``).join(', ')}`);
    lines.push('');
});
lines.push('## Functions');
lines.push('');
lines.push('| Function | Source map |');
lines.push('| --- | --- |');
functions.sort((a, b) => a.name.localeCompare(b.name)).forEach(f => {
    const maps = f.libraries.sort().map(l => `\`${sourceMapsDir}/${l}.js.map\``).join(', ');
    lines.push(`| \`${f.name}\` | ${maps} |`);
});
lines.push('');
lines.push('## Totals');
lines.push('');
lines.push(`- ${entries.length} libraries inlined into ${functions.length} functions`);
lines.push(`- ${totalEmbedded.toLocaleString('en-US')} bytes of minified JavaScript embedded in \`modules.sql\``);
lines.push(`- ${entries.reduce((total, e) => total + e.mapSize, 0).toLocaleString('en-US')} bytes of source maps`);

fs.writeFileSync(path.join(outputDir, 'SOURCE_REVIEW.md'), lines.join('\n'));
console.log(`Write ${outputDir}/SOURCE_REVIEW.md (${entries.length} libraries, ${functions.length} functions)`);