from python_utils.run_query import run_query


def test_st_relatebool_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2) AS geomA,
  @@DB_SCHEMA@@.ST_MAKEBBOX(1, 1, 3, 3) AS geomB
)
SELECT @@DB_SCHEMA@@.ST_RELATEBOOL(geomA, geomB, '212101212') FROM t;"""
    result = run_query(query)
    assert result[0][0] is True
