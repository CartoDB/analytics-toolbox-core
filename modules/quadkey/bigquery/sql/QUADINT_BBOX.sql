----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__N`
(y FLOAT64,z FLOAT64)
RETURNS FLOAT64
AS (
    ACOS(-1)*(1-2*y/POW(2,z))
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__TILE_TOLAT`
(y FLOAT64,z FLOAT64)
RETURNS FLOAT64
AS (
    COALESCE(
        180/ACOS(-1)*ATAN(0.5*(
        EXP(`@@BQ_PREFIX@@carto.__N`(y,z))
        -EXP(-`@@BQ_PREFIX@@carto.__N`(y,z))
        )),
    ERROR('NULL argument passed to UDF')
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__TILE_TOLONG`
(x FLOAT64, z FLOAT64)
RETURNS FLOAT64
AS (
    COALESCE(
    (x)/POW(2,z)*360-180,
    ERROR('NULL argument passed to UDF')
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADINT_BBOX_E`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@carto.__TILE_TOLONG`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).x+1, `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADINT_BBOX_W`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@carto.__TILE_TOLONG`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).x, `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADINT_BBOX_N`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@carto.__TILE_TOLAT`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).y, `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADINT_BBOX_S`
(quadint INT64)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@carto.__TILE_TOLAT`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).y+1, `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_BBOX`
(quadint INT64)
RETURNS ARRAY<FLOAT64>
AS (
    [
        `@@BQ_PREFIX@@carto.__QUADINT_BBOX_W`(quadint),
        `@@BQ_PREFIX@@carto.__QUADINT_BBOX_S`(quadint),
        `@@BQ_PREFIX@@carto.__QUADINT_BBOX_E`(quadint),
        `@@BQ_PREFIX@@carto.__QUADINT_BBOX_N`(quadint)
    ]
);