# CARTO Analytics Toolbox for Redshift

The Analytics Toolbox for Redshift contains SQL functions and Python libraries. The functions are deployed in a schema called `carto` inside a specific database. The Python libraries are installed in the Redshift cluster, so they can be used by all the databases in the cluster. An S3 bucket is required as intermediate storage to create the libraries. In Redshift, the functions can be used with tables of the same database, but different schemas.

Note: Redshift UDFs only support Python2 but the Python Redshift connector is only available in Python3. Therefore, both Python versions are required to develop the toolbox.

## Tools

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `Python2`: https://www.python.org/downloads/release/python-2718/ (v2.7.18)
- `Python3`: https://www.python.org/downloads/release/python-3811 (v3.8.11)
- `aws`: https://aws.amazon.com/cli/ (v2.4)
- `jq`: https://stedolan.github.io/jq/ (v1.6)
- `virtualenv`: https://virtualenv.pypa.io/en/latest/ (v20.11)

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox.

```
# Redshift
RS_PREFIX=
RS_HOST=your-redshift-host-url.redshift.amazonaws.com
RS_DATABASE=your-redshift-database
RS_USER=your-redshift-user
RS_PASSWORD=your-redshift-password
RS_BUCKET=s3://your-s3-bucket/
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-access-key
```

## Structure

- `common`
- `libraries`
    - `python`: Python library
        - `lib`: contains the Python code
        - `test`: contains the library tests
- `modules`
    - `doc`: contains the functions' documentation
    - `sql`: contains the functions' SQL code
    - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (flake8) and fixes the trivial issues (brunette)
- `make build`: builds the final SQL scripts and libraries (zip)
- `make deploy`: builds and deploys the libraries in the Redshift cluster, and SQL scripts in the Redshift database
- `make test`: runs the library tests locally and the modules tests with the Redshift database (pytest)
- `make remove`: removes all the libraries and SQL scripts from the Redshift cluster and database
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates the installation package in the dist folder (zip)

Make commands can be run also inside `libraries/python` and `modules` folders, or be called like `make lint-libraries`, `make deploy-modules`.

**Filtering**

Commands `build-modules`, `deploy-modules`, `test-modules` and `create-package` can be filtered by the following. All the filters are additive:
- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

For example:

```
make build diff=modules/quadbin/test/test_QUADBIN_RESOLUTION.py
make deploy modules=quadbin,constructors
make test functions=ST_MAKEENVELOPE
```

Additionally, `deploy-libraries` can be filtered with `library=carto` to deploy only the carto Python library and skip the dependencies, which don't change as often.
