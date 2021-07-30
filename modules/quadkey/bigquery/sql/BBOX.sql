----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__N`
(y FLOAT64,z FLOAT64)
RETURNS FLOAT64
AS (
    ACOS(-1)*(1-2*y/POW(2,z))
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__TILE2LAT`
(y FLOAT64,z FLOAT64)
RETURNS FLOAT64
AS (
    COALESCE(
        180/ACOS(-1)*ATAN(0.5*(
        EXP(`@@BQ_PREFIX@@quadkey.__N`(y,z))
        -EXP(-`@@BQ_PREFIX@@quadkey.__N`(y,z))
        )),
    ERROR('NULL argument passed to UDF')
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__TILE2LON`
(x FLOAT64, z FLOAT64)
RETURNS FLOAT64
AS (
    COALESCE(
    (x)/POW(2,z)*360-180,
    ERROR('NULL argument passed to UDF')
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__BBOX_E`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@quadkey.__TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x + 1, `@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__BBOX_W`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@quadkey.__TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x, `@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__BBOX_N`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@quadkey.__TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y, `@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__BBOX_S`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@quadkey.__TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+1, `@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.BBOX`
(quadint INT64)
RETURNS ARRAY<FLOAT64>
AS (
    [
        `@@BQ_PREFIX@@quadkey.__BBOX_W`(quadint),
        `@@BQ_PREFIX@@quadkey.__BBOX_S`(quadint),
        `@@BQ_PREFIX@@quadkey.__BBOX_E`(quadint),
        `@@BQ_PREFIX@@quadkey.__BBOX_N`(quadint)
    ]
);