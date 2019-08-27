CREATE OR REPLACE FUNCTION jslibs.quadkey.kRing(quadkey STRING, ringSize NUMERIC)
 RETURNS ARRAY<STRING>
 LANGUAGE js AS
"""
//Only support for Rings=1
return [
	sibling(quadkey,'left'),
	sibling(quadkey,'right'),
	sibling(quadkey,'up'),
	sibling(quadkey,'down'),
	quadkey
];
"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey/latest/index.js"]
);