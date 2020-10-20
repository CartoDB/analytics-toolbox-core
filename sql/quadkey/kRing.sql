CREATE OR REPLACE FUNCTION jslibs.quadkey.kRing(quadkey STRING, ringSize NUMERIC)
 RETURNS ARRAY<STRING>
 LANGUAGE js AS
"""
var left      = sibling(quadkey,'left');
var topleft   = sibling(left,'up');
var downleft  = sibling(left,'down');
var right     = sibling(quadkey,'right');
var topright  = sibling(right,'up');
var downright = sibling(right,'down');
var up        = sibling(quadkey,'up');
var down      = sibling(quadkey,'down');

return [left,topleft,downleft,right,topright,downright,up,down,quadkey];

"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);