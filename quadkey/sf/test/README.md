# Snowflake integration tests

These are integration tests for quadkey under Snowflake. Divided in 2 categories:

  * Those ending in `_integration.js`. They are integration tests, they use [Snowflake Node.js Driver](https://docs.snowflake.com/en/user-guide/nodejs-driver.html) so they require authentication. They require `SF_DATABASEID` and `SF_SCHEMA_QUADKEY` environment variables to be defined with the project and dataset where the functions are stored and where tables will be created, and they also require SNOWSQL credentials (can be passed in a file using `SNOWSQL_ACCOUNT`, `SNOWSQL_USER` and `SNOWSQL_PWD` environment variables). Check SNOWFLAKE.md in the project root for more information on how to set these variables.
  * Those ending in `_integration_standalone.js`. Integration tests that can't be executed in parallel with anything else.

Important notes:
  * The tests NEED to be independent as they are executed in parallel. The exception are the `standalone` ones.
  * The integration tests are, by Snowflake nature, pretty slow.

  In order to run all the integration tests simply call:
 
```bash
make check-integration
```
