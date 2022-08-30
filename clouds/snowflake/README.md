# CARTO Analytics Toolbox for Snowflake

The Analytics Toolbox for Snowflake contains SQL functions and JavaScript libraries. The functions are deployed in a schema called `carto` inside a specific database. The JavaScript libraries are deployed inside the SQL functions. In Snowflake, the functions can be used with tables of any database in the same account.

## Tools

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `node`: https://www.npmjs.com/ (v14.18)
- `yarn`: https://yarnpkg.com/ (v1.22)

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox.

```
# Snowflake
SF_PREFIX=
SF_ACCOUNT=your-snowflake-account
SF_DATABASE=your-snowflake-database
SF_USER=your-snowflake-user
SF_PASSWORD=your-snowflake-password
SF_ROLE=your-snowflake-role
SF_SHARE_PREFIX=
SF_SHARE_ENABLED=0
```

## Structure

- `common`
- `libraries`
    - `javascript`: JavaScript library
        - `libs`: contains the JavaScript module-specific code
        - `src`: contains the JavaScript source code
        - `test`: contains the library tests
- `modules`
    - `doc`: contains the functions' documentation
    - `sql`: contains the functions' SQL code
    - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (eslint) and fixes the trivial issues
- `make build`: builds the final SQL scripts and libraries (JS)
- `make deploy`: builds the JS libraries and SQL scripts and deploys in the Snowflake database
- `make test`: runs the library tests locally and the modules tests with the Snowflake database (jest)
- `make remove`: removes the SQL scripts from the Snowflake database
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates the installation package in the dist folder (zip)

Make commands can be run also inside `libraries/javascript` and `modules` folders, or be called like `make lint-libraries`, `make deploy-modules`.

**Filtering**

Commands `build-modules`, `build-libraries`, `deploy-modules`, `test-modules` and `create-package` can be filtered by the following. All the filters are additive:
- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

For example:

```
make build diff=modules/quadbin/test/test_QUADBIN_RESOLUTION.py
make deploy modules=quadbin,constructors
make test functions=ST_MAKEENVELOPE
```

Additionally, `nodeps=1` filter can be passed to skip building and including the dependencies. It can be used to speed up re-deployments during development.
