CREATE OR REPLACE FUNCTION jslibs.sphericalmercator.bbox(x NUMERIC, y NUMERIC,zoom NUMERIC )
  RETURNS ARRAY<FLOAT64>
  LANGUAGE js AS
"""

	var merc = new SphericalMercator({
	    size: 256
	});

	return merc.bbox(x,y,zoom);

"""
OPTIONS (
  library=["gs://bigquery-jslibs/sphericalmercator.js"]
);
