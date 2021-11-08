#!/usr/bin/env node

// This script return the name of SQL functions
// declared in a file

const fs = require('fs');
const path = require('path');

const inputFiles = process.env.INPUT_FILES || '';
const cloud = process.env.CLOUD || '';
const current_module = process.env.MODULE || '';
const ignoredFiles = process.env.IGNORE || '';
const qualifyFunctions = process.env.QUALIFY || false;
const asJSON = process.env.ASJSON || false;
const includePrivateFiles = process.env.INCLUDE_PRIVATE || false;
const outputFormat = process.env.OUTPUT_FORMAT || ''; //Accepted values 'args'|'argTypes'
const outputDelimiter = process.env.DELIMITER || '\n';

let functionEndingPattern;
switch (cloud) 
{
case 'postgres': functionEndingPattern = 'BEGIN'; break;
default: functionEndingPattern = 'RETURNS'; break;
}

let output = asJSON ? {} : [];
function addFunctSignature (moduleName, functSignature) {
    if (asJSON)
    {
        if (!output[moduleName])
        {
            output[moduleName] = [];
        }
        output[moduleName].push(functSignature);
    }
    else
    {
        if (qualifyFunctions != '')
        {
            functSignature = moduleName + '.' + functSignature;
        }
        if (!output.includes(functSignature))
        {
            output.push(functSignature);
        }
    }
}

function classifyFunctions (moduleName, functionMatches)
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
            const functSignature = functName + '(' + functArgsTypes.join(',') + ')';
            addFunctSignature(moduleName, functSignature);
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
            addFunctSignature(moduleName, functSignature);
        }
        else
        {
            addFunctSignature(moduleName, functName);
        }
    }
}

function addFile (moduleName, fileName)
{
    if (ignoredFiles.includes(path.parse(fileName).name)) {
        return;
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
    classifyFunctions(moduleName, functionMatches);
    const procedureMatches = content.matchAll(new RegExp('(?<=PROCEDURE)(.*?)(?=BEGIN)','g'));
    classifyFunctions(moduleName, procedureMatches);
}    

if (inputFiles != '')
{
    inputFiles.split(/\n|,| /).forEach(file => {
        addFile(file.match('modules/(.*?)/')[1], file);
    });
}
else
{
    if (current_module != '')
    {
        const dir = 'sql'
        const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql'));
        files.forEach(file => {
            addFile(current_module, path.join(dir,file));
        });
    }
    else
    {
        const dir = 'modules'
        const modules = fs.readdirSync(dir);
        modules.forEach(module => {
            const sqldir = path.join(dir, module, cloud, 'sql');
            if (fs.existsSync(sqldir)) {
                const files = fs.readdirSync(sqldir);
                files.forEach(file => {
                    addFile(module, path.join(sqldir,file));
                });
            }
        });
    }
}

if (asJSON)
{
    process.stdout.write(JSON.stringify(output));
}
else
{
    if (output.length > 0)
    {
        process.stdout.write(output.join(outputDelimiter) + outputDelimiter);
    }
}