#!/usr/bin/env node

// Build the setup_script for the native app installer setup file

// ./build_native_app_setup_script.js modules --output=build --libs_build_dir=../libraries/javascript/build native_app_dir=../native_app --production --dropfirst

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const outputDir = argv.output || 'build';
const libsBuildDir = argv.libs_build_dir || '../libraries/javascript/build';
const nativeAppDir = argv.native_app_dir || '../native_app';

// Replace environment variables
let separator;
if (argv.production) {
    separator = '\n';
} else {
    separator = '\n-->\n';  // marker to future SQL split
}
let content = fs.readFileSync(path.resolve(nativeAppDir, 'SETUP_SCRIPT.sql')).toString();

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

let additionalTables = '';
if (argv.production) {
    additionalTables = fs.readFileSync(path.resolve(nativeAppDir, 'ADDITIONAL_TABLES.sql')).toString() + separator;
}

content = header + separator + additionalTables + content;

content = apply_replacements(content);

// Write setup_script.sql file
fs.writeFileSync(path.join(outputDir, 'setup_script.sql'), content);
console.log(`Write ${outputDir}/setup_script.sql`);