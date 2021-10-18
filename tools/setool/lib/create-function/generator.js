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
    let content;
    switch (cloud){
    case 'bigquery':
    case 'snowflake':
        content = `### ${fname}

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

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

\`\`\`sql
SELECT ${project}.${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')});
-- TODO
\`\`\``;
        break;
    case 'redshift':
        content = `### ${fname}

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

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

\`\`\`sql
SELECT ${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')});
-- TODO
\`\`\``;
        break;
    }
    createFile([root, 'modules', mname, cloud, 'doc', `${fname}.md`], content);
}

function createSQLFunction () {
    let content = '';
    switch (cloud){
    case 'bigquery':
        switch (ftemplate){
        case 'js':
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
            break;

        case 'sql':
            content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${mname}.${fname}\`
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS ((
    TODO
));`;
            break;

        case 'js-combo':
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
            break;

        case 'sql-combo':
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
            break;
        default:
            throw ftemplate + ' function template not existing in ' + cloud;
        }
        break;

    case 'snowflake':
        switch (ftemplate){
        case 'js':
            content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    TODO
$$;`;
            break;

        case 'sql':
            content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
AS $$
    TODO
$$;`;
            break;

        case 'js-combo':
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
            break;

        case 'sql-combo':
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
            break;
        default:
            throw ftemplate + ' function template not existing in ' + cloud;
        }

        // Create SHARE
        let shareContent = readFile([root, 'modules', mname, cloud, 'sql', '_SHARE_CREATE.sql']);
        shareContent += `
grant usage on function @@SF_PREFIX@@${mname}.${fname}(${fparams.map(fp => fp.type).join(',')}) to share @@SF_SHARE@@;`
    
        createFile([root, 'modules', mname, cloud, 'sql', '_SHARE_CREATE.sql'], shareContent);

        break;

    case 'redshift':
        switch (ftemplate){
        case 'sql':
            content = `${header}

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${mname}.${fname}
(${fparams.map(fp => fp.type).join(', ')})
-- (${fparams.map(fp => fp.name).join(', ')})
RETURNS ${frtype}
IMMUTABLE
AS $$
    TODO
$$ LANGUAGE sql;`;

            break;
        case 'python':
            content = `${header}

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${mname}.${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
IMMUTABLE
AS $$
    from @@RS_PREFIX@@${mname}Lib import 
        
    TODO
$$ LANGUAGE plpythonu;`;
            break;
        case 'sql-combo':
            content = `${header}

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${mname}._${fname}
(${fparams.map(fp => fp.type).join(', ')})
-- (${fparams.map(fp => fp.name).join(', ')})
RETURNS ${frtype}
IMMUTABLE
AS $$   
    TODO
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${mname}.${fname}
(${fparams.map(fp => fp.type).join(', ')})
-- (${fparams.map(fp => fp.name).join(', ')})
RETURNS ${frtype}
IMMUTABLE
AS $$   
    SELECT @@RS_PREFIX@@${mname}._${fname}(${fparams.map(fp => fp.name).join(', ')})
$$ LANGUAGE sql;`;
            break;
        case 'python-combo':
            content = `${header}

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${mname}._${fname}
(${fparams.map(fp => `${fp.name} ${fp.type}`).join(', ')})
RETURNS ${frtype}
IMMUTABLE
AS $$
    from @@RS_PREFIX@@${mname}Lib import 
        
    TODO
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${mname}.${fname}
(${fparams.map(fp => fp.type).join(', ')})
-- (${fparams.map(fp => fp.name).join(', ')})
RETURNS ${frtype}
IMMUTABLE
AS $$   
    SELECT @@RS_PREFIX@@${mname}._${fname}(${fparams.map(fp => fp.name).join(', ')})
$$ LANGUAGE sql;`;
            break;
        default:
            throw ftemplate + ' function template not existing in ' + cloud;
        }
        break;
    }
    createFile([root, 'modules', mname, cloud, 'sql', `${fname}.sql`], content);
}

function CreateTestIntegrationFunction () {
    let content;

    switch (cloud){
    case 'bigquery':
        if (['sql', 'sql-combo', 'js', 'js-combo'].includes(ftemplate)) {
            content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');

test('${fname} should work', async () => {
    const query = 'SELECT \`@@BQ_PREFIX@@${mname}.${fname}\`(${fparams.map(fp => fp.name).join(', ')}) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].output).toEqual();
});`;

            createFile([root, 'modules', mname, cloud, 'test', 'integration', `${fname}.test.js`], content);
        }
        break;

    case 'snowflake':
        if (['sql', 'sql-combo', 'js', 'js-combo'].includes(ftemplate)) {
            content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');

test('${fname} should work', async () => {
    const query = 'SELECT @@SF_PREFIX@@${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')}) AS output';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].OUTPUT).toEqual();
});`;

            createFile([root, 'modules', mname, cloud, 'test', 'integration', `${fname}.test.js`], content);
        }
        break;

    case 'redshift':
        if (['sql', 'sql-combo', 'python', 'python-combo'].includes(ftemplate)) {
            content = `from test_utils import run_query


def test_${fname.toLowerCase()}():
    result = run_query('SELECT @@RS_PREFIX@@${mname}.${fname}(${fparams.map(fp => fp.name).join(', ')})')
    assert result[0][0] == `;

            createFile([root, 'modules', mname, cloud, 'test', 'integration', `test_${fname}.py`], content);
        }
        break;
    }
}