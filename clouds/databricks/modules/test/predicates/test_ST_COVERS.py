import os
from python_utils.test_utils import run_query

def test_st_covers_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 3, 3) AS geomA,
  @@DB_SCHEMA@@.ST_MAKEBBOX(1, 1, 2, 2) as geomB
)
SELECT @@DB_SCHEMA@@.ST_COVERS(geomA, geomB) FROM t;"""
    result = run_query(query)
    assert result[0][0] == True