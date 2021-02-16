-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROJ@@.PROJ`
    (fromProjection STRING, toProjection STRING,coordinates ARRAY<FLOAT64>)
    RETURNS ARRAY<FLOAT64>
    LANGUAGE js
    OPTIONS (library=["@@PROJ_BQ_LIBRARY@@"])
    AS
"""
    return proj4(fromProjection,toProjection,coordinates);  
""";
