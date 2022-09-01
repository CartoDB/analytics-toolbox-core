import os
from python_utils.test_utils import run_query

def test_st_within_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_POINT(1, 1) AS geomA,
  @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2) AS geomB
)
SELECT @@DB_SCHEMA@@.ST_WITHIN(geomA, geomB) FROM t;"""
    result = run_query(query)
    assert result[0][0] == True