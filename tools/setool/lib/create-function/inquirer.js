const inquirer = require('inquirer');

module.exports = {
    askFunctionDetails: (info) => {
        const questions = [];

        !info.module && questions.push({
            type: 'input',
            name: 'mname',
            message: 'Enter the name of the module:',
            validate: (value) => {
                if (value.length) {
                    if (value === value.toLowerCase()) {
                        return true;
                    } else {
                        return 'Please enter the name in lowercase.';
                    }
                } else {
                    return 'Please enter the name of the module.';
                }
            }
        });

        !info.cloud && questions.push({
            type: 'list',
            name: 'cloud',
            message: 'Select the cloud for the function:',
            choices: ['bigquery', 'snowflake', 'redshift'],
            default: 'bigquery'
        });

        questions.push({
            type: 'input',
            name: 'fname',
            message: 'Enter a name for the function:',
            validate: (value) => {
                if (value.length) {
                    if (value === value.toUpperCase()) {
                        return true;
                    } else {
                        return 'Please enter the name in uppercase.';
                    }
                } else {
                    return 'Please enter a name for the function.';
                }
            }
        });
        
        questions.push({
            type: 'input',
            name: 'fpnames',
            message: 'Enter the input parameter names:',
            suffix: ' (separated by semicolons)',
            filter: (value) => {
                return value.replace(/;\s+/g, ';').split(';').filter(p => p);
            }
        });

        questions.push({
            type: 'input',
            name: 'fptypes',
            message: 'Enter the input parameter types:',
            suffix: ' (separated by semicolons)',
            filter: (value) => {
                return value.replace(/;\s+/g, ';').split(';').filter(p => p);
            }
        });

        questions.push({
            type: 'input',
            name: 'frtype',
            message: 'Enter the return type:'
        });
        
        questions.push({
            type: 'list',
            name: 'ftemplate',
            message: 'Select the template for the function:',
            choices: ['js', 'sql', 'python', 'js-combo', 'sql-combo', 'python-combo'],
            default: 'js'
        });

        return inquirer.prompt(questions);
    }
};