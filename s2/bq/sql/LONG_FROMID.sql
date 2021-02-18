-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.LONG_FROMID`
    (id STRING)
    RETURNS FLOAT64
    DETERMINISTIC
    LANGUAGE js 
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    return S2.idToLatLng(id)["lng"];
""";