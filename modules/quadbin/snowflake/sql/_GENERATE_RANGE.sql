----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _GENERATE_RANGE
(min REAL, max REAL)
RETURNS VARIANT
LANGUAGE JAVASCRIPT
AS $$
  if (MAX < MIN) {
    return null;
  }
  return Array(MAX - MIN + 1).fill().map((x,i) => i + MIN);
$$;