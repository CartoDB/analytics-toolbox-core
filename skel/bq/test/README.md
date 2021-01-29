# BigQuery integration tests

These are integration tests for the tiler under BigQuery. Divided in 2 categories:

  * Those ending in `_integration.js`. They are integration tests, they use BigQuery so they require authentication. They require `BQ_PROJECTID` and `SKEL_BQ_DATASET` environment variables to be defined with the project and dataset where the functions are stored and where tables will be created, and they also require BQ credentials (can be passed in a file using `GOOGLE_APPLICATION_CREDENTIALS` environment variable). Check BIGQUERY.md in the project root for more information on how to set these variables.
  * Those ending in `_integration_standalone.js`. Integration tests that can't be executed in parallel with anything else.

Important notes:
  * The tests NEED to be independent as they are executed in parallel. The exception are the `standalone` ones.
  * The integration tests are, by BigQuery nature, pretty slow.

  In order to run all the integration tests simply call:
 
```bash
make check-integration
```
