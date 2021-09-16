const inquirer  = require('./inquirer');
const { createDir, createFile, currentDate, capitalize } = require('../utils');

const header = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------`;

let root;
let name;
let cloud;
let type;

module.exports = {
    createModule: async (info) => {
        const response = await inquirer.askModuleDetails(info);

        root = info.root;
        name = response.name;
        cloud = response.cloud;
        type = info.type || response.type;

        createModule();
    }
};

function createModule () {
    createDir([root, 'modules']);
    createDir([root, 'modules', name]);
    createDir([root, 'modules', name, cloud]);
    createDir([root, 'modules', name, cloud, 'doc']);
    createDir([root, 'modules', name, cloud, 'lib']);
    createDir([root, 'modules', name, cloud, 'sql']);
    createDir([root, 'modules', name, cloud, 'test']);
    createDir([root, 'modules', name, cloud, 'test', 'unit']);
    createDir([root, 'modules', name, cloud, 'test', 'integration']);

    createDocIntro();
    createDocVersion();
    createLibIndex();
    createSQLVersion();
    if (cloud === 'snowflake') {
        createSQLShares();
    }
    createTestIntegrationVersion();
    createTestUnitIndex();
    createChangelog();
    createMakefile();
    if (cloud === 'bigquery' || cloud === 'snowflake') {
        createPackage();
    }
    createReadme();
}

function createDocIntro () {
    const content = `## ${name}

<div class="badges"><div class="${type}"></div></div>

TODO.`;

    createFile([root, 'modules', name, cloud, 'doc', '_INTRO.md'], content);
}

function createDocVersion () {
    const project = { bigquery: 'bqcarto', snowflake: 'sfcarto' }[cloud];
    let content;
    switch (cloud){
    case 'bigquery':
    case 'snowflake':
        content = `### VERSION

{{% bannerNote type="code" %}}
${name}.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the ${name} module.

**Return type**

\`STRING\`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

\`\`\`sql
SELECT ${project}.${name}.VERSION();
-- 1.0.0
\`\`\``;
        break;

    case 'redshift':
        content = `### VERSION

{{% bannerNote type="code" %}}
${name}.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the ${name} module.

**Return type**

\`VARCHAR\`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

\`\`\`sql
SELECT ${name}.VERSION();
-- 1.0.0
\`\`\``;
        break;
    }

    createFile([root, 'modules', name, cloud, 'doc', 'VERSION.md'], content);
}

function createLibIndex () {
    const filename = { bigquery: 'index.js', snowflake: 'index.js', redshift: '__init__.py' }[cloud];
    let content;
    switch (cloud){
    case 'bigquery':
    case 'snowflake':
        content = `import { version }  from '../package.json';

export default {
    version
};`;

        createFile([root, 'modules', name, cloud, 'lib', 'index.js'], content);
        break;

    case 'redshift':
        content = '__version__ = \'1.0.0\'\n';  
        break;
    }

    createFile([root, 'modules', name, cloud, 'lib', filename], content);
}

function createSQLVersion () {
    let content;
    switch (cloud){
    case 'bigquery':
        content = `${header}

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${name}.VERSION\`
()
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return ${name}Lib.version;
""";`;
        break;

    case 'snowflake':
        content = `${header}

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${name}.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    return ${name}Lib.version;
$$;`;
        break;

    case 'redshift':
        content = `${header}

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@${name}.VERSION
() 
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@${name}Lib import __version__
    return __version__
$$ LANGUAGE plpythonu;`;
        break;
    }

    createFile([root, 'modules', name, cloud, 'sql', 'VERSION.sql'], content);
}

function createSQLShares () {
    let content = `${header}

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function @@SF_PREFIX@@${name}.VERSION() to share @@SF_SHARE@@;`;

    createFile([root, 'modules', name, cloud, 'sql', '_SHARE_CREATE.sql'], content);

    content = `${header}

USE role ACCOUNTADMIN;
DROP SHARE @@SF_SHARE@@;`;

    createFile([root, 'modules', name, cloud, 'sql', '_SHARE_REMOVE.sql'], content);
}

function createTestIntegrationVersion () {
    const filename = { bigquery: 'VERSION.test.js', snowflake: 'VERSION.test.js', redshift: 'test_VERSION.py' }[cloud];
    const cover = { bigquery: '`', snowflake: '' }[cloud];
    const variable = { bigquery: 'v', snowflake: 'V' }[cloud];
    const prefix = { bigquery: 'BQ_PREFIX', snowflake: 'SF_PREFIX', redshift: 'RS_PREFIX' }[cloud];
    let content;
    switch (cloud){
    case 'bigquery':
    case 'snowflake':
        content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');
const version = require('../../package.json').version;

test('VERSION returns the proper version', async () => {
    const query = 'SELECT ${cover}@@${prefix}@@${name}.VERSION${cover}() as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].${variable}).toEqual(version);
});`;
        break;

    case 'redshift':
        content = `import os
import sys

# Include this to allow importing lib from source code
sys.path.insert(
    1, os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..')
)
sys.path.insert(
    1,
    os.path.join(
        os.path.dirname(os.path.realpath(__file__)),
        '..',
        '..',
        '..',
        '..',
        '..',
        'common',
        'redshift',
    ),
)
`;

        createFile([root, 'modules', name, cloud, 'test', 'integration', '__init__.py'], content);

        content = `from lib import __version__
from test_utils import run_query


def test_version():
    result = run_query('SELECT @@${prefix}@@${name}.VERSION()')
    assert result[0][0] == __version__
`;
        break;
    }

    createFile([root, 'modules', name, cloud, 'test', 'integration', filename], content);
}

function createTestUnitIndex () {
    const filename = { bigquery: 'VERSION.test.js', snowflake: 'VERSION.test.js', redshift: 'test_VERSION.py' }[cloud];
    let content;
    switch (cloud){
    case 'bigquery':
    case 'snowflake':
        content = `const ${name}Lib = require('../../dist/index');
const version = require('../../package.json').version;

test('${name} library defined', () => {
    expect(${name}Lib.version).toBe(version);
});`;
        break;

    case 'redshift':
        content = `import os
import sys

# Include this to allow importing lib from source code
sys.path.insert(
    1, os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..')
)
`;

        createFile([root, 'modules', name, cloud, 'test', 'unit', '__init__.py'], content);

        content = `from lib import ${name}Lib, __version__


def test_init():
    assert ${name}Lib.__version__ == __version__
`;
        break;
        
    }

    createFile([root, 'modules', name, cloud, 'test', 'unit', filename], content);
}

function createChangelog () {
    const content = `# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - ${currentDate()}

### Added
- Create ${name} module.
- Add VERSION function.`;

    createFile([root, 'modules', name, cloud, 'CHANGELOG.md'], content);
}

function createMakefile () {
    const content = `MODULE = ${name}

include ../../../common/${cloud}/Makefile`;

    createFile([root, 'modules', name, cloud, 'Makefile'], content);
}

function createPackage () {
    const cname = capitalize(name);
    const ccloud = { bigquery: 'BigQuery', snowflake: 'Snowflake' }[cloud];
    const content = `{
  "name": "${name}_${cloud}",
  "version": "1.0.0",
  "description": "${cname} module for ${ccloud}",
  "author": "CARTO",
  "license": "BSD-3-Clause",
  "private": true,
  "dependencies": {
  }
}`;

    createFile([root, 'modules', name, cloud, 'package.json'], content);
}

function createReadme () {
    const cname = capitalize(name);
    const ccloud = { bigquery: 'BigQuery', snowflake: 'Snowflake', redshift: 'Redshift' }[cloud];
    const content = `# ${cname} module for ${ccloud}

TODO: add module description.`;

    createFile([root, 'modules', name, cloud, 'README.md'], content);
}