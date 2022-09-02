from python_utils.test_utils import run_query


def test_st_equals_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING (0 0, 2 2)') AS lineA,
  @@DB_SCHEMA@@.ST_GEOMFROMWKT('LINESTRING (0 0, 1 1, 2 2)') AS lineB
)
SELECT @@DB_SCHEMA@@.ST_EQUALS(lineA, lineB) FROM t;"""
    result = run_query(query)
    assert result[0][0] is True
