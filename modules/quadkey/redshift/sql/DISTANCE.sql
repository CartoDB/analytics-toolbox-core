----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.f_distance
(x1 float, y1 float, x2 float, y2 float) 
RETURNS float 
IMMUTABLE
AS $$ 
    from trig.line import LineSegment
    return LineSegment(x1, y1, x2, y2).distance()
$$ LANGUAGE plpythonu;