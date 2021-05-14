const inquirer  = require('./inquirer');
const { createDir, createFile, currentDate, capitalize } = require('../utils');

module.exports = {
    createModule: async () => {
        const { name, cloud, type } = await inquirer.askModuleDetails();
        createModule(name, cloud, type);
    }
};

function createModule (name, cloud, type) {
    createDir(['modules']);
    createDir(['modules', name]);
    createDir(['modules', name, cloud]);
    createDir(['modules', name, cloud, 'doc']);
    createDir(['modules', name, cloud, 'lib']);
    createDir(['modules', name, cloud, 'sql']);
    createDir(['modules', name, cloud, 'test']);
    createDir(['modules', name, cloud, 'test', 'unit']);
    createDir(['modules', name, cloud, 'test', 'integration']);

    createDocIntro(name, cloud, type);
    createDocVersion(name, cloud);
    createLibIndex(name, cloud);
    createSQLVersion(name, cloud);
    if (cloud === 'snowflake') {
        createSQLShares(name, cloud);
    }
    createTestIntegrationVersion(name, cloud);
    createTestUnitIndex(name, cloud);
    createChangelog(name, cloud);
    createMakefile(name, cloud);
    createPackage(name, cloud);
    createReadme(name, cloud);
}

function createDocIntro (name, cloud, type) {
    const content = `## ${name}

<div class="badge ${type}"></div>

TODO: add module description.`;

    createFile(['modules', name, cloud, 'doc', '_INTRO.md'], content);
}

function createDocVersion (name, cloud) {
    const project = { bigquery: 'bqcarto', snowflake: 'sfcarto' }[cloud];
    const content = `### VERSION

{{% bannerNote type="code" %}}
${name}.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the ${name} module.

**Return type**

\`STRING\`

**Example**

\`\`\`sql
SELECT ${project}.${name}.VERSION();
-- 1.0.0
\`\`\``;

    createFile(['modules', name, cloud, 'doc', 'VERSION.md'], content);
}

function createLibIndex (name, cloud) {
    const content = `import { version }  from '../package.json';

export {
    version
};`;

    createFile(['modules', name, cloud, 'lib', 'index.js'], content);
}

function createSQLVersion (name, cloud) {
    let content = '';
    if (cloud === 'bigquery') {
        content = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION \`@@BQ_PREFIX@@${name}.VERSION\`
()
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return lib.version;
""";`;
    }
    if (cloud === 'snowflake') {
        content = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@${name}.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    return lib.version;
$$;`;
    }

    createFile(['modules', name, cloud, 'sql', 'VERSION.sql'], content);
}

function createSQLShares (name, cloud) {
    let content = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_PREFIX@@${name}.VERSION() to share @@SF_SHARE_PUBLIC@@;`;

    createFile(['modules', name, cloud, 'sql', '_SHARE_CREATE.sql'], content);

    content = `----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

DROP SHARE @@SF_SHARE_PUBLIC@@;`;

    createFile(['modules', name, cloud, 'sql', '_SHARE_REMOVE.sql'], content);
}

function createTestIntegrationVersion (name, cloud) {
    const cover = { bigquery: '`', snowflake: '' }[cloud];
    const variable = { bigquery: 'v', snowflake: 'V' }[cloud];
    const prefix = { bigquery: 'BQ_PREFIX', snowflake: 'SF_PREFIX' }[cloud];
    const content = `const { runQuery } = require('../../../../../common/${cloud}/test-utils');
const version = require('../../package.json').version;

test('VERSION returns the proper version', async () => {
    const query = 'SELECT ${cover}@@${prefix}@@${name}.VERSION${cover}() as v';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].${variable}).toEqual(version);
});`;

    createFile(['modules', name, cloud, 'test', 'integration', 'VERSION.test.js'], content);
}

function createTestUnitIndex (name, cloud) {
    const content = `const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.version).toBe(version);
});`;

    createFile(['modules', name, cloud, 'test', 'unit', 'index.test.js'], content);
}

function createChangelog (name, cloud) {
    const content = `# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - ${currentDate()}

### Added
* Initial implementation of the module.`;

    createFile(['modules', name, cloud, 'CHANGELOG.md'], content);
}

function createMakefile (name, cloud) {
    const content = `MODULE = ${name}

include ../../../common/${cloud}/Makefile`;

    createFile(['modules', name, cloud, 'Makefile'], content);
}

function createPackage (name, cloud) {
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

    createFile(['modules', name, cloud, 'package.json'], content);
}

function createReadme (name, cloud) {
    const cname = capitalize(name);
    const ccloud = { bigquery: 'BigQuery', snowflake: 'Snowflake' }[cloud];
    const content = `# ${cname} module for ${ccloud}

TODO: add module description.`;

    createFile(['modules', name, cloud, 'README.md'], content);
}