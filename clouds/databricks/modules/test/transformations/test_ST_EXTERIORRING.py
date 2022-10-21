from python_utils.run_query import run_query


def test_st_exteriorring_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 1, 1) AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_EXTERIORRING(geom)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'LINESTRING (0 0, 0 1, 1 1, 1 0, 0 0)'
