# BigQuery integration tests

These are integration tests for the tiler under BigQuery. Divided in 2 categories:

  * Those ending in `_integration.js`. They are integration tests, they use BigQuery so they require authentication. They require `BQ_DATASET` and `BQ_PROJECTID` environment variables to be defined with the project and dataset where the functions are stored and where tables will be created, and they also require BQ credentials (can be passed in a file using `GOOGLE_APPLICATION_CREDENTIALS` environment variable). Check BIGQUERY.md in the project root for more information on how to set these variables.
  * Those ending in `_integration_standalone.js`. Integration tests that can't be executed in parallel with anything else.

Important notes:
  * The tests NEED to be independent as they are executed in parallel. The exception are the `standalone` ones.
  * The integration tests are, by BigQuery nature, pretty slow.
  * To run the integration test, you need your account (session_user()) to be added to the limits table. In development and CI this table is created using the `sql/sample_limits.csv` which is deployed when creating the dataset (sql/Makefile :: create_dataset). In these environments you can also modify it manually (see limits_integration_standalone.js tests for some examples).
  * Although we try to clean up after the integration tests they might leave directories named after the last commit in the cartobq project (both in the dataset and in storage); those can be deleted safely.

  In order to run all the integration tests simply call:
 
```bash
make check_integration
```