const inquirer = require('inquirer');

module.exports = {
    askModuleDetails: (info) => {
        const questions = [{
            type: 'input',
            name: 'name',
            message: 'Enter a name for the module:',
            validate: (value) => {
                if (value.length) {
                    if (value === value.toLowerCase()) {
                        return true;
                    } else {
                        return 'Please enter the name in lowercase.';
                    }
                } else {
                    return 'Please enter a name for the module.';
                }
            }
        }, {
            type: 'list',
            name: 'cloud',
            message: 'Select the cloud for the module:',
            choices: ['bigquery', 'snowflake'],
            default: 'bigquery'
        }];
        !info.type && questions.push({
            type: 'list',
            name: 'type',
            message: 'Select the type of module:',
            choices: ['core', 'advanced'],
            default: 'core'
        });
        return inquirer.prompt(questions);
    }
};