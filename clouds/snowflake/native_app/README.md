## ANALYTICS TOOLBOX CORE INSTALLER

### Introduction

The CARTO Analytics Toolbox for Snowflake is composed of a set of user-defined functions and procedures organized in a set of modules based on the functionality they offer. This app gives you access to the Open Source modules included in the CARTO's Analytics Toolbox, supporting different spatial indexes and other geospatial operations: quadkeys, H3, S2, placekey, geometry constructors, accessors, transformations, etc.

We recommend that at the moment of installing the app you name the app "CARTO". The next guidelines and examples will assume that in order to simplify the onboarding process.

### Installation

#### Install the Analytics Toolbox

This Native App is an installer so it does not contain the actual Analytics Toolbox functions and procedures. The next steps are required in order to install the Analytics Toolbox in a defined SCHEMA.

```
-- Set create function and procedure permissions
GRANT USAGE ON DATABASE CARTO_DATA_ENGINEERING_TEAM TO APPLICATION CARTO;
GRANT USAGE, CREATE FUNCTION, CREATE PROCEDURE ON SCHEMA <DATABASE>.<SCHEMA> TO APPLICATION CARTO;

-- Generate the installer procedure in the specified location
CALL CARTO.CARTO.GENERATE_INSTALLER('<DATABASE>.<SCHEMA>');

-- Update ownership of the install procedure
GRANT OWNERSHIP ON PROCEDURE <DATABASE>.<SCHEMA>.INSTALL(STRING, STRING) TO ROLE ACCOUNTADMIN;

-- Install the Analytics Toolbox in <DATABASE>.<SCHEMA>
CALL <DATABASE>.<SCHEMA>.INSTALL('CARTO', '<DATABASE>.<SCHEMA>');
```

### Usage Examples

Please refer to CARTO's [SQL reference](https://docs.carto.com/data-and-analysis/analytics-toolbox-for-snowflake/sql-reference) to find the full list of available functions and procedures as well as examples.

#### H3_POLYFILL

Returns an array with all the H3 cell indexes **with centers** contained in a given polygon.

```
SELECT carto.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4);
-- 842da29ffffffff
-- 843f725ffffffff
-- 843eac1ffffffff
-- 8453945ffffffff
-- ...
```

Learn how to visualize the result of these queries in CARTO by visiting [https://docs.carto.com/carto-user-manual/maps/data-sources#add-source-from-a-custom-query](https://docs.carto.com/carto-user-manual/maps/data-sources#add-source-from-a-custom-query).

Get a CARTO account in [https://app.carto.com/signup](https://app.carto.com/signup).