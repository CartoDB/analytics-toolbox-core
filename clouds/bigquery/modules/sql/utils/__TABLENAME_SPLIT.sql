----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__TABLENAME_SPLIT`
(qualified_name STRING)
RETURNS STRUCT<project STRING, dataset STRING, table STRING>
AS ((
    WITH unquoted AS (SELECT REPLACE(qualified_name, "`", "") AS name)

    SELECT AS STRUCT
        REGEXP_EXTRACT(name, r"^(.+)\..+\..+$") AS project,
        COALESCE(REGEXP_EXTRACT(name, r"^.+\.(.+)\..+$"), REGEXP_EXTRACT(name, r"^(.+)\..+$")) AS dataset,
        REGEXP_EXTRACT(name, r"^.+\.(.+)$") AS table
    FROM unquoted
));
