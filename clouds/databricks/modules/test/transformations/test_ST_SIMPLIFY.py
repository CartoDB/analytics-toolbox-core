from python_utils.run_query import run_query


def test_st_simplify_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_BUFFERPOINT(@@DB_SCHEMA@@.ST_POINT(0, 0), 10) AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_SIMPLIFY(geom, 0.00001)) AS simplifiedGeom,
    @@DB_SCHEMA@@.ST_NUMPOINTS(@@DB_SCHEMA@@.ST_SIMPLIFY(geom, 0.00001)) AS simplifiedNumpoints,
    @@DB_SCHEMA@@.ST_NUMPOINTS(geom) AS numPoints FROM t;"""
    result = run_query(query)
    assert (
        result[0][0]
        == 'POLYGON ((0.00009 0, 0.00008 0.00005, 0.00003 0.00009, -0.00005 0.00008, -0.00009 0.00003, -0.00008 -0.00005, -0.00003 -0.00009, 0.00005 -0.00008, 0.00008 -0.00005, 0.00009 0))'
    )
    assert result[0][1] == 10
    assert result[0][2] == 69
