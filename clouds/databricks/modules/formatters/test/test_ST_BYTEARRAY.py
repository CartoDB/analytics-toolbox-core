import os
from test_utils.utils import run_query

def test_st_bytearray_success():
    query = "SELECT @@DB_SCHEMA@@.ST_BYTEARRAY('POINT (-76.0913 18.4275)');"
    result = run_query(query)
    assert result[0][0] == b"POINT (-76.0913 18.4275)"