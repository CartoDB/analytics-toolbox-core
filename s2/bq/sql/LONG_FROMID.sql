-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.LONG_FROMID`
    (id BIGNUMERIC)
    RETURNS FLOAT64
    DETERMINISTIC
    LANGUAGE js 
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    if(id == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    return S2.idToLatLng(id)["lng"];
""";