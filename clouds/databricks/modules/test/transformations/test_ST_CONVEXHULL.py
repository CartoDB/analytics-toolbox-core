from python_utils.test_utils import run_query


def test_st_convexhull_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOMFROMWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 5),POLYGON((-1 -1, -1 -5, -5 -5, -5 -1, -1 -1)))') AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_CONVEXHULL(geom)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((-5 -5, -5 -1, 3 5, -1 -5, -5 -5))'
