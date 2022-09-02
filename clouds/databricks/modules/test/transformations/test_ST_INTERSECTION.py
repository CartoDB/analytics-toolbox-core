from python_utils.test_utils import run_query


def test_st_intersection_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 2, 2) AS geomA,
  @@DB_SCHEMA@@.ST_MAKEBBOX(1, 1, 3, 3) AS geomB
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_INTERSECTION(geomA, geomB)) AS intersection FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((1 2, 2 2, 2 1, 1 1, 1 2))'
