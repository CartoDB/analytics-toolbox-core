import json
import pytest

from test_utils.integration.redshift import run_query


@pytest.mark.integration
def test_st_generatepoints():
    result = run_query("""SELECT @@RS_SCHEMA@@.ST_GENERATEPOINTS(
            ST_GEOMFROMTEXT('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'), 10)""")
    assert len(json.loads(result[0][0])["coordinates"]) == 10
