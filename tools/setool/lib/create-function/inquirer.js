const inquirer = require('inquirer');

module.exports = {
    askFunctionDetails: () => {
        const questions = [{
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
        }, {
            type: 'list',
            name: 'cloud',
            message: 'Select the cloud for the function:',
            choices: ['bigquery', 'snowflake'],
            default: 'bigquery'
        }, {
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
        }, {
            type: 'input',
            name: 'fparams',
            message: 'Enter the input parameters:',
            suffix: ' (separated by commas)',
            filter: (value) => {
                return value.replace(/\s/g, '').split(',').filter(p => p);
            }
        }, {
            type: 'list',
            name: 'ftype',
            message: 'Select the type of function:',
            choices: ['js', 'sql', 'js-combo', 'sql-combo'],
            default: 'js'
        }];
        return inquirer.prompt(questions);
    }
};
