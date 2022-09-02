from python_utils.test_utils import run_query


def test_st_boundary_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2) AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_BOUNDARY(geom)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'LINESTRING (0 0, 0 2, 2 2, 2 0, 0 0)'
