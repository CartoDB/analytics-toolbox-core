-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.H3_FROMINT`(index INT64)
    RETURNS STRING
AS
(
    FORMAT("%x", index)
);

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.H3_ASINT`(index STRING)
    RETURNS INT64
AS
(
    SAFE_CAST(CONCAT('0x', index) AS INT64)
);