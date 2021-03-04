# Placekey

Based on https://github.com/Placekey/placekey-js. Changes done:
  * Removed the dependency on h3.min.js by keeping only the transformations to and from h3 and the validation.
  * Removed the tests of unused features.

Depends on the h3 module functions (to convert to HEX).

## Folder structure

bq/      - Files necessary to generate BigQuery UDFs.
library/ - Base code used to generate the final JS library.
