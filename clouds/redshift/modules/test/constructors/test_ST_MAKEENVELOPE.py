from test_utils import run_query


def test_st_makeenvelope_success():
    result = run_query(
        """
        WITH __input AS (
            SELECT 10.0 xmin, 10.0 ymin, 11.0 xmax, 11.0 ymax UNION ALL
            SELECT -179.0, 10.0, 179.0, 11.0 UNION ALL
            SELECT 179.0, 10.0, -179.0, 11.0
        )
        SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_MAKEENVELOPE(xmin, ymin, xmax, ymax))
        FROM __input
    """
    )

    assert result[0][0] == 'POLYGON((10 10,10 11,11 11,11 10,10 10))'
    assert result[1][0] == 'POLYGON((-179 10,-179 11,179 11,179 10,-179 10))'
    assert result[2][0] == 'POLYGON((179 10,179 11,-179 11,-179 10,179 10))'


def test_st_makeenvelope_null():
    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.ST_MAKEENVELOPE(NULL, 10.0, 11.0, 11.0),
               @@RS_SCHEMA@@.ST_MAKEENVELOPE(10.0, NULL, 11.0, 11.0),
               @@RS_SCHEMA@@.ST_MAKEENVELOPE(10.0, 10.0, NULL, 11.0),
               @@RS_SCHEMA@@.ST_MAKEENVELOPE(10.0, 10.0, 11.0, NULL)
    """
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None
    assert result[0][3] is None
