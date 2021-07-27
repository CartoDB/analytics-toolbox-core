----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.BBOX`(quadint INT64)
RETURNS ARRAY<FLOAT64> AS ([
`@@BQ_PREFIX@@quadkey._BBOX_E`(quadint),
`@@BQ_PREFIX@@quadkey._BBOX_W`(quadint),
`@@BQ_PREFIX@@quadkey._BBOX_S`(quadint),
`@@BQ_PREFIX@@quadkey._BBOX_N`(quadint)
]);