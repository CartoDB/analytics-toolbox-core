from python_utils.run_query import run_query

# FIXME:
# databricks.sql.exc.ServerOperationError: Job aborted due to stage failure:
# com/carto/hiveless/spatial/util/TWKBWriter has been compiled by a more recent
# version of the Java Runtime (class file version 55.0), this version of the Java
# Runtime only recognizes class file versions up to 52.0


def test_st_extenttogeom_success():
    query = """WITH t AS (
  SELECT @@DB_SCHEMA@@.ST_EXTENTFROMGEOM(@@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 1, 1)) as extent
)
SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_EXTENTTOGEOM(extent)) FROM t;"""
    result = run_query(query)
    assert result[0][0] == 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))'
