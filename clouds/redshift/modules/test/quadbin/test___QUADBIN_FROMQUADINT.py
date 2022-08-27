from test_utils import run_query


def test___quadbin_fromquadint():
    result = run_query('SELECT @@RS_SCHEMA@@.__QUADBIN_FROMQUADINT(12521547919)')

    assert len(result[0]) == 1
    assert result[0][0] == 5256684166837174271
