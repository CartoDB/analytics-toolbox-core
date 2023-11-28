## ANALYTICS TOOLBOX CORE

### Introduction


### Installation

#### Step 1: Grant Usage

```
-- Set read and write permissions
GRANT USAGE ON DATABASE <database> TO APPLICATION CARTO;
GRANT ALL ON SCHEMA <database>.<schema> TO APPLICATION CARTO;
GRANT ALL ON SCHEMA <database>.<schema> TO APPLICATION CARTO;
GRANT SELECT ON ALL TABLES IN SCHEMA <database>.<schema> TO APPLICATION CARTO;

-- Update ownership (when a table is created the app is the ownser)
GRANT OWNERSHIP ON TABLE <database>.<schema>.<output_table> TO ROLE ACCOUNTADMIN;
```
