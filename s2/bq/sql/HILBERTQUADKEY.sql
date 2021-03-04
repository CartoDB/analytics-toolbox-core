-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ID_FROMHILBERTQUADKEY`
    (quadkey STRING)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    if(!quadkey)
    {
        throw new Error('NULL argument passed to UDF');
    }

    return S2.keyToId(quadkey).toString();
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.HILBERTQUADKEY_FROMID`
    (id INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    if(id == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    return S2.idToKey(id);
""";
