#!/usr/bin/env node

// This script return the name of SQL functions
// declared in a file

const fs = require('fs');
const { exit } = require('process');

const output = [];
const cloud = process.env.CLOUD || '';
const ignoredFiles = process.env.IGNORE || '';
const includePrivateFiles = process.env.INCLUDE_PRIVATE || false;
const fileName = process.env.FILE_NAME || '';
const functSchema = process.env.FUNCT_SCHEMA || '';
const outputFormat = process.env.OUTPUT_FORMAT || ''; //Accepted values 'args'|'argTypes'

let functionEndingPattern;
switch (cloud) 
{
case 'postgres': functionEndingPattern = 'BEGIN'; break;
default: functionEndingPattern = 'RETURNS'; break;
}

if (ignoredFiles.includes(fileName)) {
    exit();
}

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

function classifyFunctions (functionMatches)
{
    for (const functionMatch of functionMatches) {
        //Remove spaces and diacritics
        let qualifiedFunctName = functionMatch[0].replace(/[ \p{Diacritic}]/gu, '').split('(')[0];
        qualifiedFunctName = qualifiedFunctName.split('.');
        const functName = qualifiedFunctName[qualifiedFunctName.length - 1];
        
        if (!includePrivateFiles && functName.startsWith('_'))
        {
            continue;
        }
    
        if (outputFormat == 'argTypes')
        {
            //Remove diacritics and go greedy to take the outer parentheses
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
            const functSignature = functName + '(' + functArgsTypes.join(', ') + ')';
            addFunctSignature(functSignature);
        }
        else if (outputFormat == 'args')
        {
            let functArgs = functionMatch[0].replace(/[\p{Diacritic}]/gu, '').matchAll(new RegExp('(?<=\\()(.*)(?=\\))','g')).next().value;
            if (functArgs)
            {
                functArgs = functArgs[0];
            }
            else
            {
                continue;
            }
    
            const functSignature = functName + '(' + functArgs + ')';
            addFunctSignature(functSignature);
        }
        else
        {
            addFunctSignature(functName);
        }
    }
}

let content = fs.readFileSync(fileName, 'utf8');
content = content.split('\n');
for (let i = 0 ; i < content.length; i++)
{
    
    if (content[i].startsWith('--'))
    {
        delete content[i];
    }
    
}
content = content.join(' ');
content = content.replace(/(\r\n|\n|\r)/gm,' ')
const functionMatches = content.matchAll(new RegExp(`(?<=FUNCTION)(.*?)(?=${functionEndingPattern})`,'g'));
classifyFunctions(functionMatches);
const procedureMatches = content.matchAll(new RegExp('(?<=PROCEDURE)(.*?)(?=BEGIN)','g'));
classifyFunctions(procedureMatches);

if (output.length > 0)
{
    process.stdout.write(output.join('\n') + '\n');
}