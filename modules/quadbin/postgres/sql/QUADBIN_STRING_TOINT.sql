----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_STRING_TOINT(
  quadbin TEXT
)
RETURNS BIGINT
 AS
$BODY$
    SELECT ('x' || quadbin)::bit(64)::BIGINT;
$BODY$
  LANGUAGE SQL;
