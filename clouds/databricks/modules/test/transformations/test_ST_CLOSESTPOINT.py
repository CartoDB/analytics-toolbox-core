from python_utils.test_utils import run_query


def test_st_closestpoint_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING (3 1, 1 3)') AS geomA,
  @@DB_SCHEMA@@.ST_POINT(0, 0) AS geomb
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_CLOSESTPOINT(geomA, geomB)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POINT (2 2)'
