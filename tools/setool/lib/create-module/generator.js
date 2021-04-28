const inquirer  = require('./inquirer');
const { createDir, createFile } = require('../utils');

module.exports = {
    createModule: async () => {
        const { name, library, clouds, visibility } = await inquirer.askModuleDetails();

        createDir([name]);
        createGitignore(name);
        createLicense(name);
        createMakefile(name);
        createReadme(name);

        if (library) {
            createLib(name);
        }

        for (let cloud of clouds) {
            switch (cloud) {
                case 'bq':
                    createBQ(name, library, visibility);
                    break;
                case 'sf':
                    createSF(name, library, visibility);
                    break;
            }
        }
    }
};

function createGitignore (name) {
    const lname = name.toLowerCase();
    const content = `${lname}_library.js`;

    createFile([name, '.gitignore'], content);
}

function createLicense (name) {
    const content = `SPDX short identifier: BSD-3-Clause

Copyright (c) 2021, CARTO
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.`;

    createFile([name, 'LICENSE'], content);
}

function createMakefile (name) {
    const lname = name.toLowerCase();
    const content = `LIBRARY = "library/"
ALL_SUBFOLDERS = $(LIBRARY) "bq/" "sf/"

ENABLED_BQ ?= 0
ENABLED_SF ?= 0

TARGET = ${lname}_library.js
.PHONY: all build check check-integration check-linter clean deploy linter $(TARGET)

all build $(TARGET):
	$(MAKE) -C library/ all

check check-linter linter:
	for s in $(LIBRARY); do \\
		$(MAKE) -C $\${s} $@ || exit 1; \\
	done;

clean:
	for s in $(ALL_SUBFOLDERS); do \\
		$(MAKE) -C $\${s} $@ || exit 1; \\
	done;

deploy check-integration:
ifeq ($(ENABLED_BQ), 1)
	$(MAKE) -C bq/ $@
endif
ifeq ($(ENABLED_SF), 1)
	$(MAKE) -C sf/ $@
endif`;

    createFile([name, 'Makefile'], content);
}

function createReadme (name) {
    const lname = name.toLowerCase();
    const content = `# ${lname}

This contains the basic folder structure for a module of the extension.`;

    createFile([name, 'README.md'], content);
}

function createLib (name) {
    const lname = name.toLowerCase();

    createDir([name, 'library']);
    createDir([name, 'library', lname]);
    createDir([name, 'library', 'test']);

    createLibEslintrc(name);
    createLibMakefile(name);
    createLibPackage(name);
    createLibSrcVersion(name);
    createLibTestMakefile(name);
    createLibTestReadme(name);
    createLibTestPackage(name);
    createLibTestUnit(name);
}

function createLibEslintrc (name) {
    const content = `module.exports = {
    env: {
        commonjs: false,
        es2020: true,
        node: false
    },
    extends: ['standard'],
    parserOptions: {
        ecmaVersion: 11,
        sourceType: "script"
    },
    rules: {
        "brace-style": ["error", "1tbs"],
        // We accept camelcase properties since the input JSONs have them and its easier to keep them as is
        "camelcase": ["error", { "properties": "never", "ignoreGlobals": true }],
        "indent": ["error", 4],
        "max-len": ["error", { "code": 120, "tabWidth": 4, "ignoreComments": true, "ignoreUrls": true, "ignoreStrings": true, "ignoreTemplateLiterals": true, "ignoreRegExpLiterals": true }],
        // Undefinition are allowed since files are checked individually, and functions might be declared in previous ones
        "no-undef": ["off"],
        "semi": ["error", "always"],
        "space-before-function-paren": ["error", "never"]
    }
};
`;

    createFile([name, 'library', '.eslintrc.js'], content);
}

function createLibMakefile (name) {
    const lname = name.toLowerCase();
    const content = `TARGET = ../${lname}_library.js

ESLINT ?= ./node_modules/eslint/bin/eslint.js
NPM ?= npm
CAT ?= cat

all: $(TARGET)

JS_FILES = \\
	${lname}/${lname}_version.js \\

.PHONY: check
check: $(TARGET)
	$(MAKE) -C test/ $@

.PHONY: clean
clean:
	rm -rf $(TARGET) node_modules/
	$(MAKE) -C test/ $@

.PHONY: clang-format check-clang-format eslint check-eslint
node_modules: package.json
	$(NPM) i

eslint: node_modules
	$(ESLINT) --fix $(JS_FILES)

check-eslint: node_modules
	$(ESLINT) $(JS_FILES)

linter: eslint

check-linter: check-eslint

$(TARGET): $(JS_FILES)
	rm -f $(TARGET)
	for n in $(JS_FILES); do \\
		$(CAT) $$n >> $(TARGET) || exit; \\
	done
`;

    createFile([name, 'library', 'Makefile'], content);
}

function createLibPackage (name) {
    const lname = name.toLowerCase();
    const content = `{
    "name": "${lname}_linter",
    "version": "1.0.0",
    "description": "",
    "main": "",
    "devDependencies": {
        "eslint": "^7.18.0",
        "eslint-config-standard": "^16.0.2",
        "eslint-plugin-import": "^2.22.1",
        "eslint-plugin-node": "^11.1.0",
        "eslint-plugin-promise": "^4.2.1"
    },
    "author": "",
    "license": "ISC"
}`;

    createFile([name, 'library', 'package.json'], content);
}

function createLibSrcVersion (name) {
    const lname = name.toLowerCase();
    const content = `// -----------------------------------------------------------------------
// --
// -- Copyright (C) 2021 CARTO
// --
// -----------------------------------------------------------------------

/* exported ${lname}Version */
function ${lname}Version() {
    return '1.0.0';
};
`;

    createFile([name, 'library', lname, `${lname}_version.js`], content);
}

function createLibTestMakefile (name) {
    const content = `TESTER ?= ./node_modules/mocha/bin/mocha

NPM ?= npm

# Nothing by default
all:

node_modules: package.json
	$(NPM) i

.PHONY: check
check: node_modules
	$(TESTER) -p -j 4 -t 10000 $(shell find . -maxdepth 1 -name "*_test.js")

.PHONY: clean
clean:
	rm -rf node_modules`;

    createFile([name, 'library', 'test', 'Makefile'], content);
}

function createLibTestReadme (name) {
    const lname = name.toLowerCase();
    const content = `# Tests

These are the set of tests that verify the behaviour of the JS library generated to support the \`${lname}\` functions. They are designed to be used under \`node\` and \`npm\` to simulate the behaviour of the library under BigQuery.

They can be divided into 2 categories:

* Those ending in \`_test.js\`. Unit tests that use the local WASM library.
* Those ending in \`_benchmark.js\` are benchmarks to check performance between versions. Used manually (not under CI).

When adding new tests make sure they are independent from each other so they can be executed in parallel without issues.

In order to run all the tests simply call:
    
\`\`\`bash
make check
\`\`\``;

    createFile([name, 'library', 'test', 'README.md'], content);
}

function createLibTestPackage (name) {
    const lname = name.toLowerCase();
    const content = `{
    "name": "${lname}_unit_tests",
    "version": "1.0.0",
    "description": "",
    "main": "${lname}_test.js",
    "scripts": {
        "test": "mocha"
    },
    "keywords": [],
    "author": "",
    "license": "ISC",
    "dependencies": {
        "mocha": "^8.2.1"
    }
}`;

    createFile([name, 'library', 'test', 'package.json'], content);
}

function createLibTestUnit (name) {
    const lname = name.toLowerCase();
    const uname = name.toLowerCase();
    const content = `const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../${lname}_library.js')+'');

describe('${uname} unit tests', () => {

    it ('Version', async () => {
        assert.equal(${lname}Version(), '1.0.0');
    });
});
`;

    createFile([name, 'library', 'test', `${lname}_test.js`], content);
}

function createBQ (name, library, visibility) {
    createDir([name, 'bq']);
    createDir([name, 'bq', 'doc']);
    createDir([name, 'bq', 'sql']);
    createDir([name, 'bq', 'test']);

    createBQMakefile(name, library, visibility);
    createBQDocReference(name, visibility);
    createBQSQLVersion(name, library);
    createBQTestMakefile(name);
    createBQTestReadme(name);
    createBQTestPackage(name);
    createBQTestIntegration(name);
}

function createBQMakefile (name, library, visibility) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const uvisibility = visibility.toUpperCase();
    const content = `# Programs
SED ?= sed
BQ ?= bq --location=$(BQ_REGION)
GSUTIL ?= gsutil

POST_INTEGRATION_CLEANUP ?= 1
${islib(`
# Deployment variables
${uname}_BQ_LIBRARY ?= $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_${uname})/${lname}_library.js

.PHONY: ../${lname}_library.js
../${lname}_library.js:
	$(MAKE) -C .. all
`)}
.PHONY: check_environment all check clean storage_upload storage_remove dataset_create dataset_remove dataset_deploy deploy check-integration integration_cleanup

check_environment:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECTID
	$(error BQ_PROJECTID is undefined)
endif
ifndef BQ_DATASET_${uname}
	$(error BQ_DATASET_${uname} is undefined)
endif
${islib(`ifndef BQ_BUCKET_${uvisibility}
	$(error BQ_BUCKET_${uvisibility} is undefined)
endif
`)}
all check:

clean:
	$(MAKE) -C test/ $@
${islib(`
##################### STORAGE FILES #####################
storage_upload: ../${lname}_library.js check_environment
	$(GSUTIL) cp -r ../${lname}_library.js $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_${uname})/

storage_remove: check_environment
	$(GSUTIL) rm -rf $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_${uname})/
`)}
##################### BIGQUERY DATASET #####################
dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECTID) show $(BQ_DATASET_${uname}) 2>/dev/null 1>/dev/null || \\
		$(BQ) mk -d --description "${uname} Dataset" $(BQ_PROJECTID):$(BQ_DATASET_${uname})

dataset_remove: check_environment
	$(BQ) rm -r -f -d $(BQ_PROJECTID):$(BQ_DATASET_${uname})

REPLACEMENTS = -e 's!@@BQ_PROJECTID@@!$(BQ_PROJECTID)!g' \\
	-e 's!@@BQ_DATASET_${uname}@@!$(BQ_DATASET_${uname})!g'${islib(` \\
	-e 's!@@${uname}_BQ_LIBRARY@@!$(${uname}_BQ_LIBRARY)!g'`)}

dataset_deploy: check_environment
	for n in $(sort $(wildcard sql/*.sql)); do \\
		$(SED) $(REPLACEMENTS) $$n | $(BQ) -q --project_id $(BQ_PROJECTID) query --use_legacy_sql=false || exit; \\
	done

##################### DEPLOY #####################
deploy: check_environment${islib(`
	$(MAKE) storage_upload`)}
	$(MAKE) dataset_create
	$(MAKE) dataset_deploy

##################### INTEGRATION TESTS #####################
check-integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP), 1)${islib(`
	$(MAKE) storage_remove`)}
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
endif`;

    function islib (text) {
        return library ? text : '';
    }

    createFile([name, 'bq', 'Makefile'], content);
}

function createBQDocReference (name, visibility) {
    const lname = name.toLowerCase();
    const badge = visibility === 'private' ? 'advanced' : 'core';
    const content = `## ${lname}

<div class="badge ${badge}"></div>

TODO: module description.

### VERSION

{{% bannerNote type="code" %}}
${lname}.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the ${lname} module.

**Return type**

\`STRING\`

**Example**

\`\`\`sql
SELECT bqcarto.${lname}.VERSION();
-- 1.0.0
\`\`\``;

    createFile([name, 'bq', 'doc', 'REFERENCE.md'], content);
}

function createBQSQLVersion (name, library) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const content = `-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION \`@@BQ_PROJECTID@@.@@BQ_DATASET_${uname}@@.VERSION\`()
    RETURNS STRING
    DETERMINISTIC${islib(`LANGUAGE js
    OPTIONS (library=["@@${uname}_BQ_LIBRARY@@"])`)}
AS """
    return ${library ? `${lname}Version()` : `'1.0.0'`};
""";`;

    function islib (text) {
        return library ? text : '';
    }

    createFile([name, 'bq', 'sql', 'VERSION.sql'], content);
}

function createBQTestMakefile (name) {
    const uname = name.toUpperCase();
    const content = `TESTER ?= ./node_modules/mocha/bin/mocha

NPM ?= npm

# Nothing by default
all:

node_modules: package.json
	$(NPM) i

BQ_PROJECTID ?= cartodb-gcp-backend-data-team
check_environment:
ifndef BQ_DATASET_${uname}
	$(error BQ_DATASET_${uname} is undefined)
endif

.PHONY: clean
clean:
	rm -rf node_modules

.PHONY: check_integration
check-integration: node_modules check_environment
	$(TESTER) -p -j $(shell find . -maxdepth 1 -name "*_integration.js" | wc -l) -t 240000 $(shell find . -maxdepth 1 -name "*_integration.js")
	$(MAKE) check_integration_standalone

# These tests need to be executed one by one because they modify the environment
.PHONY: check_integration_standalone
check-integration-standalone: node_modules check_environment
	$(TESTER) -t 240000 $(shell find . -maxdepth 1 -name "*_integration_standalone.js")`;

    createFile([name, 'bq', 'test', 'Makefile'], content);
}

function createBQTestReadme (name) {
    const lname = name.toUpperCase();
    const uname = name.toUpperCase();
    const content = `# BigQuery integration tests

These are integration tests for the \`${lname}\` functions under BigQuery. Divided in 2 categories:

* Those ending in \`_integration.js\`. They are integration tests, they use BigQuery so they require authentication. They require \`BQ_PROJECTID\` and \`BQ_DATASET_${uname}\` environment variables to be defined with the project and dataset where the functions are stored and where tables will be created, and they also require BQ credentials (can be passed in a file using \`GOOGLE_APPLICATION_CREDENTIALS\` environment variable). Check BIGQUERY.md in the project root for more information on how to set these variables.
* Those ending in \`_integration_standalone.js\`. Integration tests that can't be executed in parallel with anything else.

Important notes:

* The tests NEED to be independent as they are executed in parallel. The exception are the \`standalone\` ones.
* The integration tests are, by BigQuery nature, pretty slow.

In order to run all the integration tests simply call:
    
\`\`\`bash
make check-integration
\`\`\``;

    createFile([name, 'bq', 'test', 'README.md'], content);
}

function createBQTestPackage (name) {
    const lname = name.toLowerCase();
    const content = `{
    "name": "${lname}_bq_integration_tests",
    "version": "1.0.0",
    "description": "",
    "main": "${lname}_integration.js",
    "scripts": {
        "test": "mocha"
    },
    "keywords": [],
    "author": "",
    "license": "ISC",
    "dependencies": {
        "@google-cloud/bigquery": "^5.3.0",
        "mocha": "^8.2.1"
    }
}`;

    createFile([name, 'bq', 'test', 'package.json'], content);
}

function createBQTestIntegration (name) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const content = `const assert = require('assert').strict;
const {BigQuery} = require('@google-cloud/bigquery');

const BQ_PROJECTID = process.env.BQ_PROJECTID;
const BQ_DATASET_${uname} = process.env.BQ_DATASET_${uname};

describe('${uname} integration tests', () => {
    const queryOptions = { 'timeoutMs' : 30000 };
    let client;
    before(async () => {
        if (!BQ_PROJECTID) {
            throw "Missing BQ_PROJECTID env variable";
        }
        if (!BQ_DATASET_${uname}) {
            throw "Missing BQ_DATASET_${uname} env variable";
        }
        client = new BigQuery({projectId: \`\${BQ_PROJECTID}\`});
    });

    it('Returns the proper version', async () => {
        const query = \`SELECT \\\`\${BQ_PROJECTID}\\\`.\\\`\${BQ_DATASET_${uname}}\\\`.VERSION() as versioncol;\`;
        let rows;
        await assert.doesNotReject(async () => {
            [rows] = await client.query(query, queryOptions);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].versioncol, '1.0.0');
    });
}); /* ${uname} integration tests */
`;

    createFile([name, 'bq', 'test', `${lname}_integration.js`], content);
}

function createSF (name, library, visibility) {
    createDir([name, 'sf']);
    createDir([name, 'sf', 'doc']);
    createDir([name, 'sf', 'sql']);
    createDir([name, 'sf', 'test']);

    createSFMakefile(name, library);
    createSFDocReference(name, visibility);
    createSFSQLVersion(name, library);
    createSFSQLShareCreate(name);
    createSFSQLShareRemove(name);
    createSFTestMakefile(name);
    createSFTestReadme(name);
    createSFTestPackage(name);
    createSFTestIntegration(name);
}

function createSFMakefile (name, library) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const content = `# Programs
SED ?= sed
SNOWSQL ?= snowsql
GSUTIL ?= gsutil

SF_SHARE_ENABLED ?= 0
POST_INTEGRATION_CLEANUP ?= 1
${islib(`
# Deployment variables
${uname}_SF_LIBRARY ?= ../${lname}_library.js

.PHONY: ../${lname}_library.js
../${lname}_library.js:
	$(MAKE) -C .. all
`)}
SQL_FILES =  $(wildcard sql/*.sql)
SHARE_CREATE_FILE = sql/_SHARE_CREATE.sql
SHARE_REMOVE_FILE = sql/_SHARE_REMOVE.sql
SQL_DEPLOYABLE = $(filter-out $(SHARE_CREATE_FILE) $(SHARE_REMOVE_FILE),$(SQL_FILES))

.PHONY: check_environment all check clean storage_upload storage_remove dataset_create dataset_remove dataset_deploy deploy check-integration integration_cleanup

check_environment:
ifndef SF_DATABASEID
	$(error SF_DATABASEID is undefined)
endif
ifndef SF_SCHEMA_${uname}
	$(error SF_SCHEMA_${uname} is undefined)
endif

all check:

clean:
	$(MAKE) -C test/ $@

##################### SNOWFLAKE SCHEMA #####################
schema_create: check_environment
	$(SNOWSQL) -q "CREATE SCHEMA IF NOT EXISTS $(SF_DATABASEID).$(SF_SCHEMA_${uname})"

schema_remove: check_environment
	$(SNOWSQL) -q "DROP SCHEMA IF EXISTS $(SF_DATABASEID).$(SF_SCHEMA_${uname}) CASCADE"

REPLACEMENTS = 	-e 's!@@SF_DATABASEID@@!$(SF_DATABASEID)!g' \\
	-e 's!@@SF_SCHEMA_${uname}@@!$(SF_SCHEMA_${uname})!g' \\
    -e 's!@@SF_SHARE_PUBLIC@@!$(SF_SHARE_PUBLIC)!g'${islib(`\\
    -e '/@@LIBRARY_FILE_CONTENT@@/ r $(${uname}_SF_LIBRARY)' \\
    -e 's!@@LIBRARY_FILE_CONTENT@@!!g'`)}

schema_deploy: check_environment
	for n in $(sort $(SQL_DEPLOYABLE)); do \\
		$(SED) $(REPLACEMENTS) $$n | $(SNOWSQL) -q "$(xargs)" || exit; \\
	done

share_create: check_environment
ifeq ($(SF_SHARE_ENABLED),1)
	$(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE) | $(SNOWSQL) -q "$(xargs)" 
endif

share_remove: check_environment
ifeq ($(SF_SHARE_ENABLED),1)
	$(SED) $(REPLACEMENTS) $(SHARE_REMOVE_FILE) | $(SNOWSQL) -q "$(xargs)" 
endif

##################### DEPLOY #####################
deploy: ../${lname}_library.js check_environment
	$(MAKE) schema_create
	$(MAKE) schema_deploy
	$(MAKE) share_create

##################### INTEGRATION TESTS #####################
check-integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP), 1)
	$(MAKE) share_remove
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
endif`;

    function islib (text) {
        return library ? text : '';
    }

    createFile([name, 'sf', 'Makefile'], content);
}

function createSFDocReference (name, visibility) {
    const lname = name.toLowerCase();
    const badge = visibility === 'private' ? 'advanced' : 'core';
    const content = `## ${lname}

<div class="badge ${badge}"></div>

TODO: module description.

### VERSION

{{% bannerNote type="code" %}}
${lname}.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the ${lname} module.

**Return type**

\`STRING\`

**Example**

\`\`\`sql
SELECT sfcarto.${lname}.VERSION();
-- 1.0.0
\`\`\``;

    createFile([name, 'sf', 'doc', 'REFERENCE.md'], content);
}

function createSFSQLVersion (name, library) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const content = `-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_${uname}@@.VERSION()
    RETURNS STRING${islib(`
    LANGUAGE JAVASCRIPT`)}
AS $$${islib(`
    @@LIBRARY_FILE_CONTENT@@`)}
    
    return ${library ? `${lname}Version()` : `'1.0.0'`};
$$;`;

    function islib (text) {
        return library ? text : '';
    }

    createFile([name, 'sf', 'sql', 'VERSION.sql'], content);
}

function createSFSQLShareCreate (name) {
    const uname = name.toUpperCase();
    const content = `USE @@SF_DATABASEID@@;
CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASEID@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASEID@@.@@SF_SCHEMA_${uname}@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_DATABASEID@@.@@SF_SCHEMA_${uname}@@.VERSION() to share @@SF_SHARE_PUBLIC@@;`;

    createFile([name, 'sf', 'sql', '_SHARE_CREATE.sql'], content);
}

function createSFSQLShareRemove (name) {
    const content = `DROP SHARE @@SF_SHARE_PUBLIC@@;`;

    createFile([name, 'sf', 'sql', '_SHARE_REMOVE.sql'], content);
}

function createSFTestMakefile (name) {
    const uname = name.toUpperCase();
    const content = `TESTER ?= ./node_modules/mocha/bin/mocha

NPM ?= npm

# Nothing by default
all:

node_modules: package.json
	$(NPM) i

check_environment:
ifndef SF_SCHEMA_${uname}
	$(error SF_SCHEMA_${uname} is undefined)
endif

.PHONY: clean
clean:
	rm -rf node_modules

.PHONY: check_integration
check-integration: node_modules check_environment
	$(TESTER) -p -j $(shell find . -maxdepth 1 -name "*_integration.js" | wc -l) -t 240000 $(shell find . -maxdepth 1 -name "*_integration.js")
	$(MAKE) check_integration_standalone

# These tests need to be executed one by one because they modify the environment
.PHONY: check_integration_standalone
check-integration-standalone: node_modules check_environment
	$(TESTER) -t 240000 $(shell find . -maxdepth 1 -name "*_integration_standalone.js")`;

    createFile([name, 'sf', 'test', 'Makefile'], content);
}

function createSFTestReadme (name) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const content = `# Snowflake integration tests

These are integration tests for ${lname} under Snowflake. Divided in 2 categories:

* Those ending in \`_integration.js\`. They are integration tests, they use [Snowflake Node.js Driver](https://docs.snowflake.com/en/user-guide/nodejs-driver.html) so they require authentication. They require \`SF_DATABASEID\` and \`SF_SCHEMA_${uname}\` environment variables to be defined with the project and dataset where the functions are stored and where tables will be created, and they also require SNOWSQL credentials (can be passed in a file using \`SNOWSQL_ACCOUNT\`, \`SNOWSQL_USER\` and \`SNOWSQL_PWD\` environment variables). Check SNOWFLAKE.md in the project root for more information on how to set these variables.
* Those ending in \`_integration_standalone.js\`. Integration tests that can't be executed in parallel with anything else.

Important notes:

* The tests NEED to be independent as they are executed in parallel. The exception are the \`standalone\` ones.
* The integration tests are, by Snowflake nature, pretty slow.

In order to run all the integration tests simply call:
    
\`\`\`bash
make check-integration
\`\`\``;

    createFile([name, 'sf', 'test', 'README.md'], content);
}

function createSFTestPackage (name) {
    const lname = name.toLowerCase();
    const content = `{
    "name": "${lname}_sf_integration_tests",
    "version": "1.0.0",
    "description": "",
    "main": "${lname}_integration.js",
    "scripts": {
        "test": "mocha"
    },
    "keywords": [],
    "author": "",
    "license": "ISC",
    "dependencies": {
        "mocha": "^8.2.1",
        "snowflake-sdk": "^1.6.0"
    }
}`;

    createFile([name, 'sf', 'test', 'package.json'], content);
}

function createSFTestIntegration (name) {
    const lname = name.toLowerCase();
    const uname = name.toUpperCase();
    const content = `const assert = require('assert').strict;
const snowflake = require('snowflake-sdk');

const SF_DATABASEID = process.env.SF_DATABASEID;
const SF_SCHEMA_${uname} = process.env.SF_SCHEMA_${uname};

function execAsync(connection, sqlText) {
    return new Promise((resolve, reject) => {
        connection.execute({
            sqlText: sqlText,
            complete: (err, stmt, rows) => {
                if (err) {
                    return reject(err);
                } 
                return resolve([stmt, rows]);
            }
        });
    });
}

describe('${uname} integration tests', () => {
    let connection;
    before(async () => {
        if (!SF_DATABASEID) {
            throw "Missing SF_DATABASEID env variable";
        }
        if (!SF_SCHEMA_${uname}) {
            throw "Missing SF_SCHEMA_${uname} env variable";
        }
        connection = snowflake.createConnection( {
            account: process.env.SNOWSQL_ACCOUNT,
            username: process.env.SNOWSQL_USER,
            password: process.env.SNOWSQL_PWD
            }
        );
        connection.connect(
            function(err, conn) {
                if (err) {
                    console.error('Unable to connect: ' + err.message);
                } 
                else {
                    // Optional: store the connection ID.
                    connection_ID = conn.getId();
                }
            }
        );
    });
  
    it ('Returns the proper version', async () => {
        const query = \`SELECT \${SF_DATABASEID}.\${SF_SCHEMA_${uname}}.VERSION() versioncol;\`;
        let statement, rows;
        await assert.doesNotReject( async () => {
            [statement, rows] = await execAsync(connection, query);
        });
        assert.equal(rows.length, 1);
        assert.equal(rows[0].VERSIONCOL, '1.0.0');
    });
}); /* ${uname} integration tests */
`;

    createFile([name, 'sf', 'test', `${lname}_integration.js`], content);
}
