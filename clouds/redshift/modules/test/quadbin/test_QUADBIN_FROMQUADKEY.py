from test_utils import run_query


def test_quadbin_fromquadkey():
    result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMQUADKEY('')")
    assert len(result[0]) == 1
    assert result[0][0] == 5192650370358181887

    result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMQUADKEY('0')")
    assert len(result[0]) == 1
    assert result[0][0] == 5193776270265024511

    result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMQUADKEY('13020310')")
    assert len(result[0]) == 1
    assert result[0][0] == 5226184719091105791

    result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMQUADKEY('0231001222')")
    assert len(result[0]) == 1
    assert result[0][0] == 5233974874938015743
