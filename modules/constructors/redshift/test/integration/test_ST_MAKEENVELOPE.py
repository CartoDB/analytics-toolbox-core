from test_utils import run_query, redshift_connector
import pytest

def test_makeenvelope_success():
    result = run_query(
        """SELECT ST_ASTEXT(@@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, 11.0, 11.0)) as poly1,
        ST_ASTEXT(@@RS_PREFIX@@constructors.ST_MAKEENVELOPE(-179.0, 10.0, 179.0, 11.0)) as poly2,
        ST_ASTEXT(@@RS_PREFIX@@constructors.ST_MAKEENVELOPE(179.0, 10.0, -179.0, 11.0)) as poly3"""
    )

    assert result[0][0] == 'POLYGON((10 10,10 11,11 11,11 10,10 10))'
    assert result[0][1] == 'POLYGON((-179 10,-179 11,179 11,179 10,-179 10))'
    assert result[0][2] == 'POLYGON((179 10,179 11,-179 11,-179 10,179 10))'
    

def test_makeenvelope_none_success():
    result = run_query(
        """SELECT @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(NULL, 10.0, 11.0, 11.0) as poly1,
               @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, NULL, 11.0, 11.0) as poly2,
               @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, NULL, 11.0) as poly3,
               @@RS_PREFIX@@constructors.ST_MAKEENVELOPE(10.0, 10.0, 11.0, NULL) as poly4"""
    )

    assert result[0][0] == None
    assert result[0][1] == None
    assert result[0][2] == None
    assert result[0][3] == None
    
