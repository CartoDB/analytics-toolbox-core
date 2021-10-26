#!/usr/bin/env node

// This script return the name of SQL functions
// declared in a file

const fs = require('fs');
const { exit } = require('process');

const output = [];
const ignoredFiles = process.env.IGNORE || '';

const fileName = process.env.FILE_NAME || '';
const functSchema = process.env.FUNCT_SCHEMA || '';
const outputFormat = process.env.OUTPUT_FORMAT || ''; //Accepted values 'args'|'argTypes'

if (ignoredFiles.includes(fileName)) {
    exit();
}

let content = fs.readFileSync(fileName, 'utf8');
content = content.replace(/(\r\n|\n|\r)/gm,' ')

let functionMatches = content.matchAll(new RegExp('(?<=FUNCTION)(.*?)(?=RETURNS)','g'));

function addFunctSignature (functSignature) {
    if (functSchema != '')
    {
        functSignature = functSchema + '.' + functSignature;
    }
    if (!output.includes(functSignature))
    {
        output.push(functSignature);
    }
}

for (const functionMatch of functionMatches) {
    //Remove spaces and diacritics
    const functName = functionMatch[0].replace(/[ \p{Diacritic}]/gu, '').matchAll(new RegExp('(?<=[.])(.*?)(?=\\()','g')).next().value[0];
 
    if (functName.startsWith('_'))
    {
        continue;
    }

    if (outputFormat == 'argTypes')
    {
        //Remove diacritics and go greedy to take the outer parentheses
        let functArgs = functionMatch[0].replace(/[\p{Diacritic}]/gu, '').matchAll(new RegExp('(?<=\\()(.*)(?=\\))','g')).next().value[0];
        
        //This does not work with BigQuery ARRAY/STRUCT
        functArgs = functArgs.split(',')
        let functArgsTypes = [];
        for (const functArg of functArgs) {
            const functArgSplitted = functArg.split(' ');
            functArgsTypes.push(functArgSplitted[functArgSplitted.length - 1]);
        }
        const functSignature = functName + '(' + functArgsTypes.join(', ') + ')';
        addFunctSignature(functSignature);
    }
    else if (outputFormat == 'args')
    {
        const functArgs = functionMatch[0].replace(/[\p{Diacritic}]/gu, '').matchAll(new RegExp('(?<=\\()(.*)(?=\\))','g')).next().value[0];
        const functSignature = functName + '(' + functArgs + ')';
        addFunctSignature(functSignature);
    }
    else
    {
        addFunctSignature(functName);
    }
}

if (output.length > 0)
{
    process.stdout.write(output.join('\n') + '\n');
}