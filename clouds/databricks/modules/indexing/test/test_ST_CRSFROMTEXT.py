import os
from test_utils.utils import run_query

def test_st_crsfromtext_success():
    query = "SELECT @@DB_SCHEMA@@.ST_CRSFROMTEXT('+proj=merc +lat_ts=56.5 +ellps=GRS80');"
    result = run_query(query)
    assert result[0][0].strip() == '+proj=merc +lat_ts=56.5 +ellps=GRS80'