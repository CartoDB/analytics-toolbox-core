import os
from test_utils.utils import run_query

def test_st_interiorringn_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOMFROMWKT('POLYGON ((10 10, 110 10, 110 110, 10 110, 10 10), (20 20, 20 30, 30 30, 30 20, 20 20), (40 20, 40 30, 50 30, 50 20, 40 20))') AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_INTERIORRINGN(geom, 1)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == "LINESTRING (20 20, 20 30, 30 30, 30 20, 20 20)"