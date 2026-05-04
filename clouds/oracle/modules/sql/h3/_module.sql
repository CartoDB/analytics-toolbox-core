----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- MLE module bundling the h3-js library and the SQL-facing exports
-- defined in libraries/javascript/libs/h3.js. Built once via rollup at
-- deploy time; PL/SQL wrappers bind to specific exports via
-- `AS MLE MODULE @@ORA_SCHEMA@@.h3_module SIGNATURE '...'`.

CREATE OR REPLACE MLE MODULE @@ORA_SCHEMA@@.h3_module
LANGUAGE JAVASCRIPT AS
@@ORA_LIBRARY_H3@@
/
