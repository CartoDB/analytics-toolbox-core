import os
from test_utils.utils import run_query

def test_st_geomfromgeohash_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_ASGEOHASH(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8) AS geohash
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_GEOMFROMGEOHASH(geohash, 8)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == "POLYGON ((-90 11.25, -90 22.5, -67.5 22.5, -67.5 11.25, -90 11.25))"