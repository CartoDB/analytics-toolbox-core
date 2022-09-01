import os
from test_utils.utils import run_query

def test_st_makebox2d_success():
    query = "SELECT @@DB_SCHEMA@@.ST_ASTEXT(@@DB_SCHEMA@@.ST_MAKEBOX2D(@@DB_SCHEMA@@.ST_MAKEPOINT(-91.8554869, 29.5060349), @@DB_SCHEMA@@.ST_MAKEPOINT(-91.8382077, 29.5307334))) AS bbox;"
    result = run_query(query)
    assert result[0][0] == "POLYGON ((-91.8554869 29.5060349, -91.8554869 29.5307334, -91.8382077 29.5307334, -91.8382077 29.5060349, -91.8554869 29.5060349))"