import os
from test_utils.utils import run_query

def test_st_overlaps_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2) AS geomA,
  @@DB_SCHEMA@@.ST_MAKEBBOX(1, 1, 3, 3) AS geomB
)
SELECT @@DB_SCHEMA@@.ST_OVERLAPS(geomA, geomB) FROM t;"""
    result = run_query(query)
    assert result[0][0] == True