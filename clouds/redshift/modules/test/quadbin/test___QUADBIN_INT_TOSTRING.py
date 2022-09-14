from test_utils import run_query


def test___quadbin_int_tostring():
    result = run_query(
        'SELECT @@RS_SCHEMA@@.__QUADBIN_INT_TOSTRING(5209574053332910079)'
    )

    assert len(result[0]) == 1
    assert result[0][0] == '484c1fffffffffff'
