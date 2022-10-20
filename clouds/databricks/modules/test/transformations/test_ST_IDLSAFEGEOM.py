from python_utils.run_query import run_query


def test_st_idlsafegeom_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_MAKEBBOX(178, 0, 190, 5) AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_IDLSAFEGEOM(geom)) AS geom FROM t;"""
    result = run_query(query)
    assert (
        result[0][0]
        == 'MULTIPOLYGON (((-180 0, -180 5, -170 5, -170 0, -180 0)), ((180 5, 180 0, 178 0, 178 5, 180 5)))'
    )
