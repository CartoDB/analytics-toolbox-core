# Quadkey

This contains all the necessary code to build, generate, test and deploy the [BigQuery User Defined Functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions) for interacting with quadkey indexes.

[Quadkey](https://wiki.openstreetmap.org/wiki/QuadTiles) is a geospatial index based on WebMercator tiles.

On our implementation we use Quadints, our own version of Quadkey stored in a INT64. Quadints have multiple advantages as faster comparision, consistent storage or better indexing.

We also provide the functions necessary to parse between Quadints and Quadkeys.

## Folder structure

bq/      - Files necessary to generate BigQuery UDFs.  
library/ - Base code used to generate the final JS library.