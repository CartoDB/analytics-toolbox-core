from test_utils import run_query


def test_makeenvelope_success():
    result = run_query(
        """SELECT ST_ASTEXT(
            @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, 11.0, 11.0)),
        ST_ASTEXT(
            @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(-179.0, 10.0, 179.0, 11.0)),
        ST_ASTEXT(
            @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(179.0, 10.0, -179.0, 11.0))"""
    )

    assert result[0][0] == 'POLYGON((10 10,10 11,11 11,11 10,10 10))'
    assert result[0][1] == 'POLYGON((-179 10,-179 11,179 11,179 10,-179 10))'
    assert result[0][2] == 'POLYGON((179 10,179 11,-179 11,-179 10,179 10))'


def test_makeenvelope_none_success():
    result = run_query(
        """SELECT @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(NULL, 10.0, 11.0, 11.0),
               @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, NULL, 11.0, 11.0),
               @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, NULL, 11.0),
               @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, 11.0, NULL)"""
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None
    assert result[0][3] is None
