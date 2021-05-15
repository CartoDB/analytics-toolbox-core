const chalk = require('chalk');
const inquirer  = require('./inquirer');
const { checkDir, createFile, readFile } = require('../utils');

const header = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------`;

module.exports = {
    createFunction: async () => {
        const { mname, cloud, fname, fparams, ftype } = await inquirer.askFunctionDetails();

        checkModule(mname, cloud);
        createDocFunction(mname, cloud, fname, fparams);
        createSQLFunction(mname, cloud, fname, fparams, ftype);
        CreateTestIntegrationFunction(mname, cloud, fname, fparams);
    }
};

function errorModule (mname, cloud) {
    return `The module "${mname}/${cloud}" does not exist.
Please create the module first:
- setool create module`;
}

function checkModule (mname, cloud) {
    if (!checkDir(['modules', mname, cloud])) {
        console.log(chalk.red(errorModule(mname, cloud)));
        process.exit(1);
    }
}

function createDocFunction (mname, cloud, fname, fparams) {
    const project = { bigquery: 'bqcarto', snowflake: 'sfcarto' }[cloud];
    let content = `### ${fname}

{{% bannerNote type="code" %}}
${mname}.${fname}(${fparams.join(', ')})
{{%/ bannerNote %}}

**Description**

TODO
${fparams.length ? `\n${fparams.map(fp => `* \`${fp}\`: \`TYPE\` TODO.\n`).join('')}` : ''}
**Constraints**

TODO

**Return type**

\`TYPE\`

**Example**

\`\`\`sql
SELECT ${project}.${mname}.${fname}(${fparams.join(', ')});
-- OUTPUT
\`\`\``;

    createFile(['modules', mname, cloud, 'doc', `${fname}.md`], content);
}

function createSQLFunction (mname, cloud, fname, fparams, ftype) {
    let content;

    if (cloud === 'bigquery' && ftype === 'js') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    TODO
""";`;
    }

    if (cloud === 'bigquery' && ftype === 'sql') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS ((
    TODO
));`;
    }

    if (cloud === 'bigquery' && ftype === 'js-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.__${fname}\`
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    TODO
""";

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS (
    \`@@BQ_PREFIX@@${mname}.__${fname}\`(${fparams.join(', ')})
);`;
    }

    if (cloud === 'bigquery' && ftype === 'sql-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.__${fname}\`
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS ((
    TODO
));

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS (
    \`@@BQ_PREFIX@@${mname}.__${fname}\`(${fparams.join(', ')})
);`;
    }

    if (cloud === 'snowflake' && ftype === 'js') {
        content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    TODO
$$;`;
    }

    if (cloud === 'snowflake' && ftype === 'sql') {
        content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS $$
    TODO
$$;`;
    }

    if (cloud === 'snowflake' && ftype === 'js-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@${mname}._${fname}
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    TODO
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS $$
    @@SF_PREFIX@@${mname}._${fname}(${fparams.map(fp => fp.toUpperCase()).join(', ')})
$$;`;
    }

    if (cloud === 'snowflake' && ftype === 'sql-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@${mname}._${fname}
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS $$
    TODO
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp} TYPE`).join(', ')})
RETURNS TYPE
AS $$
    @@SF_PREFIX@@${mname}._${fname}(${fparams.map(fp => fp.toUpperCase()).join(', ')})
$$;
`;
    }

    createFile(['modules', mname, cloud, 'sql', `${fname}.sql`], content);

    if (cloud === 'snowflake') {
        content = readFile(['modules', mname, cloud, 'sql', '_SHARE_CREATE.sql']);
        content += `
grant usage on function @@SF_PREFIX@@${mname}.${fname}(${Array(fparams.length).fill('TYPE').join(', ')}) to share @@SF_SHARE_PUBLIC@@;`
    
        createFile(['modules', mname, cloud, 'sql', '_SHARE_CREATE.sql'], content);
    }
}

function CreateTestIntegrationFunction (mname, cloud, fname, fparams) {
    let content;

    if (cloud === 'bigquery') {
        content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');

test('${fname} should work', async () => {
    const query = 'SELECT \`@@BQ_PREFIX@@${mname}.${fname}\`(${fparams.join(', ')}) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});`;
    }

    if (cloud === 'snowflake') {
        content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');

test('{fname} should work', async () => {
    const query = 'SELECT @@SF_PREFIX@@${mname}.${fname}(${fparams.join(', ')}) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual();
});`;
    }

    createFile(['modules', mname, cloud, 'test', 'integration', `${fname}.test.js`], content);
}