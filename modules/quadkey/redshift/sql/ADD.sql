----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

create or replace function @@RS_PREFIX@@quadkey.add
(a float, b float)
  returns float
stable
as $$
  return a + b
$$ language plpythonu;