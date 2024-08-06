## ANALYTICS TOOLBOX CORE INSTALLER

### Introduction

The CARTO Analytics Toolbox for Snowflake is composed of a set of user-defined functions and procedures organized in a set of modules based on the functionality they offer. This app gives you access to the Open Source modules included in the CARTO's Analytics Toolbox, supporting different spatial indexes and other geospatial operations: quadkeys, H3, S2, placekey, geometry constructors, accessors, transformations, etc.

### Installation

#### Install the Analytics Toolbox

This Native App is an installer so it does not contain the actual Analytics Toolbox functions and procedures. For the sake of documenting the process, we'll will assume a database named CARTO, as well as a schema named CARTO in that database, also we assume the app to be called CARTO_INSTALLER. The next guidelines and examples will assume that in order to simplify the onboarding process.

All the database, schema and user can have a different name, but remember to adapt the code snippets accordingly.

```
-- Set admin permissions
USE ROLE ACCOUNTADMIN;

-- Create the carto database
CREATE DATABASE CARTO;

-- Create the carto schema
CREATE SCHEMA CARTO.CARTO;

-- Grant all to sysadmin role
GRANT ALL ON SCHEMA CARTO.CARTO TO ROLE SYSADMIN;

-- Set create function and procedure permissions
GRANT USAGE ON DATABASE CARTO TO APPLICATION CARTO_INSTALLER;
GRANT USAGE, CREATE FUNCTION, CREATE PROCEDURE ON SCHEMA CARTO.CARTO TO APPLICATION CARTO_INSTALLER;

-- Generate the installer procedure in the specified location
CALL CARTO_INSTALLER.CARTO.GENERATE_INSTALLER('CARTO.CARTO');

-- Update ownership of the install procedure
GRANT OWNERSHIP ON PROCEDURE CARTO.CARTO.INSTALL(STRING, STRING) TO ROLE ACCOUNTADMIN REVOKE CURRENT GRANTS;

-- Grant usage to public role
GRANT USAGE ON DATABASE CARTO TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA CARTO.CARTO TO ROLE PUBLIC;
GRANT SELECT ON FUTURE TABLES IN SCHEMA CARTO.CARTO TO ROLE PUBLIC;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA CARTO.CARTO TO ROLE PUBLIC;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA CARTO.CARTO TO ROLE PUBLIC;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA CARTO.CARTO TO ROLE PUBLIC;

-- Install the Analytics Toolbox in CARTO.CARTO
CALL CARTO.CARTO.INSTALL('CARTO_INSTALLER', 'CARTO.CARTO');
```

### Usage Examples

Please refer to CARTO's [SQL reference](https://docs.carto.com/data-and-analysis/analytics-toolbox-for-snowflake/sql-reference) to find the full list of available functions and procedures as well as examples.

#### H3_POLYFILL

Returns an array with all the H3 cell indexes **with centers** contained in a given polygon.

```
SELECT CARTO.CARTO.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4);
-- 842da29ffffffff
-- 843f725ffffffff
-- 843eac1ffffffff
-- 8453945ffffffff
-- ...
```

Learn how to visualize the result of these queries in CARTO by visiting [https://docs.carto.com/carto-user-manual/maps/data-sources#add-source-from-a-custom-query](https://docs.carto.com/carto-user-manual/maps/data-sources#add-source-from-a-custom-query).

Get a CARTO account in [https://app.carto.com/signup](https://app.carto.com/signup).