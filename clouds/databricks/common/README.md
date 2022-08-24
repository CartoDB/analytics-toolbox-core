# Create Integration Test Script
AT databricks support the automatic creation of integration tests from the doc file examples

`cd clouds/databricks/commons`

`./createIT.sh`

After the creation of the tests you may need to adapt the expected result in the test to the real result, boolean, integer, etc