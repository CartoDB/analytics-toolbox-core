import os
from test_utils.utils import run_query

def test_st_contains_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2) AS geom,
  @@DB_SCHEMA@@.ST_MAKEPOINT(1, 1) as Point
)
SELECT @@DB_SCHEMA@@.ST_CONTAINS(geom, point) FROM t;"""
    result = run_query(query)
    assert result[0][0] == True