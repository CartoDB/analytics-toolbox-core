# Quadkey

On this module we use Quadints, our own version of [Quadkeys](https://wiki.openstreetmap.org/wiki/QuadTiles) stored in a INT64. Quadints have multiple advantages as faster comparision, consistent storage or better indexing.

We also provide the functions necessary to parse between Quadints and Quadkeys.

## Folder structure

bq/      - Files necessary to generate BigQuery UDFs.  
sf/      - Files necessary to generate Snowflake UDFs.  
library/ - Base code used to generate the final JS library.