----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__TABLENAME_JOIN`
(split_name STRUCT<project STRING, dataset STRING, table STRING>)
RETURNS STRING
AS (
    IF(
        split_name.project IS NULL,
        FORMAT('`%s`.`%s`', split_name.dataset, split_name.table),
        FORMAT('`%s`.`%s`.`%s`', split_name.project, split_name.dataset, split_name.table)
    )
);
