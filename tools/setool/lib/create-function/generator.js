const chalk = require('chalk');
const inquirer  = require('./inquirer');
const { checkDir, createFile, readFile } = require('../utils');

const header = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------`;

let root;
let mname;
let cloud;
let fname;
let frtype;
let ftemplate;
const fparams = [];

module.exports = {
    createFunction: async (info) => {
        const response = await inquirer.askFunctionDetails(info);

        root = info.root;
        mname = info.module || response.mname;
        cloud = info.cloud  || response.cloud;
        fname = response.fname;
        response.fpnames.forEach((value, index) => {
            fparams.push({
                name: value,
                type: response.fptypes.length > index ? response.fptypes[index] : 'TODO'
            })
        });
        frtype = response.frtype || 'TODO';
        ftemplate = response.ftemplate;

        checkModule();
        createDocFunction();
        createSQLFunction();
        CreateTestIntegrationFunction();
    }
};

function errorModule () {
    return `The module "${mname}/${cloud}" does not exist.
Please create the module first:
- setool create module`;
}

function checkModule () {
    if (!checkDir([root, 'modules', mname, cloud])) {
        console.log(chalk.red(errorModule(mname, cloud)));
        process.exit(1);
    }
}

function createDocFunction () {
    const project = { bigquery: 'bqcarto', snowflake: 'sfcarto' }[cloud];
    let content = `### ${fname}

{{% bannerNote type="code" %}}
${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')})
{{%/ bannerNote %}}

**Description**

TODO.
${fparams.length ? `\n${fparams.map(fp => `* \`${fp.name}\`: \`${fp.type}\` TODO.\n`).join('')}` : ''}
**Constraints**

TODO.

**Return type**

\`${frtype}\`

**Example**

\`\`\`sql
SELECT ${project}.${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')});
-- TODO
\`\`\``;

    createFile([root, 'modules', mname, cloud, 'doc', `${fname}.md`], content);
}

function createSQLFunction () {
    let content;

    if (cloud === 'bigquery' && ftemplate === 'js') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    TODO
""";`;
    }

    if (cloud === 'bigquery' && ftemplate === 'sql') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS ((
    TODO
));`;
    }

    if (cloud === 'bigquery' && ftemplate === 'js-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.__${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    TODO
""";

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS (
    \`@@BQ_PREFIX@@${mname}.__${fname}\`(${fparams.map(fp => fp.name).join(', ')})
);`;
    }

    if (cloud === 'bigquery' && ftemplate === 'sql-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.__${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS ((
    TODO
));

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS (
    \`@@BQ_PREFIX@@${mname}.__${fname}\`(${fparams.map(fp => fp.name).join(', ')})
);`;
    }

    if (cloud === 'snowflake' && ftemplate === 'js') {
        content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    TODO
$$;`;
    }

    if (cloud === 'snowflake' && ftemplate === 'sql') {
        content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS $$
    TODO
$$;`;
    }

    if (cloud === 'snowflake' && ftemplate === 'js-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@${mname}._${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    TODO
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS $$
    @@SF_PREFIX@@${mname}._${fname}(${fparams.map(fp => fp.name.toUpperCase()).join(', ')})
$$;`;
    }

    if (cloud === 'snowflake' && ftemplate === 'sql-combo') {
        content = `${header}

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@${mname}._${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS $$
    TODO
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS $$
    @@SF_PREFIX@@${mname}._${fname}(${fparams.map(fp => fp.name.toUpperCase()).join(', ')})
$$;
`;
    }

    createFile([root, 'modules', mname, cloud, 'sql', `${fname}.sql`], content);

    if (cloud === 'snowflake') {
        content = readFile(['modules', mname, cloud, 'sql', '_SHARE_CREATE.sql']);
        content += `
grant usage on function @@SF_PREFIX@@${mname}.${fname}(${Array(fparams.length).fill('TODO').join(',')}) to share @@SF_SHARE@@;`
    
        createFile([root, 'modules', mname, cloud, 'sql', '_SHARE_CREATE.sql'], content);
    }
}

function CreateTestIntegrationFunction () {
    let content;

    if (cloud === 'bigquery') {
        content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');

test('${fname} should work', async () => {
    const query = 'SELECT \`@@BQ_PREFIX@@${mname}.${fname}\`(${fparams.map(fp => fp.name).join(', ')}) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});`;
    }

    if (cloud === 'snowflake') {
        content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');

test('{fname} should work', async () => {
    const query = 'SELECT @@SF_PREFIX@@${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')}) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual();
});`;
    }

    createFile([root, 'modules', mname, cloud, 'test', 'integration', `${fname}.test.js`], content);
}