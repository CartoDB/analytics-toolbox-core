const inquirer = require('inquirer');

module.exports = {
    askModuleDetails: () => {
        const questions = [{
            type: 'input',
            name: 'name',
            message: 'Enter a name for the module:',
            validate: (value) => {
                if (value.length) {
                    return true;
                } else {
                    return 'Please enter a name for the module.';
                }
            }
        }, {
            type: 'list',
            name: 'visibility',
            message: 'Public or private:',
            choices: ['public', 'private'],
            default: 'public'
        }, {
            type: 'checkbox',
            name: 'clouds',
            message: 'Select the clouds you wish to create:',
            choices: ['bq', 'sf'],
            default: 'bq',
            validate: (value) => {
                if (value.length) {
                    return true;
                } else {
                    return 'Please select at least one cloud.';
                }
            }
        }, {
            type: 'confirm',
            name: 'library',
            message: 'Do you want to create a JS library?:',
            default: true
        }];
        return inquirer.prompt(questions);
    }
};
