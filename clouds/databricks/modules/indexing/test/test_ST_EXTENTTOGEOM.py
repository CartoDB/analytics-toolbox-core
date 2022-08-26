import os
from test_utils.utils import run_query

def test_st_extenttogeom_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_EXTENTFROMGEOM(@@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 1, 1)) as extent
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_EXTENTTOGEOM(extent)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == "POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))"