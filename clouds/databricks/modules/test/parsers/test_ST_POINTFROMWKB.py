import os
from python_utils.test_utils import run_query

def test_st_pointfromwkb_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_ASBINARY(@@DB_SCHEMA@@.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)')) AS wkb
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_POINTFROMWKB(wkb)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == "POINT (-76.0913 18.4275)"