import os
from test_utils.utils import run_query

def test_st_intersects_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING (1 0, 1 2)') AS lineA,
  @@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING (0 1, 2 1)') AS lineB
)
SELECT @@DB_SCHEMA@@.ST_INTERSECTS(lineA, lineB) FROM t;"""
    result = run_query(query)
    assert result[0][0] == True