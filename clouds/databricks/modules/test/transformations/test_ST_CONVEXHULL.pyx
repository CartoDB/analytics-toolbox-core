from python_utils.run_query import run_query

# FIXME:
# databricks.sql.exc.ServerOperationError: Job aborted due to stage failure:
# com/carto/hiveless/spatial/util/TWKBWriter has been compiled by a more recent
# version of the Java Runtime (class file version 55.0), this version of the Java
# Runtime only recognizes class file versions up to 52.0


def test_st_convexhull_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_GEOMFROMWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 5),POLYGON((-1 -1, -1 -5, -5 -5, -5 -1, -1 -1)))') AS geom
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_CONVEXHULL(geom)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((-5 -5, -5 -1, 3 5, -1 -5, -5 -5))'
