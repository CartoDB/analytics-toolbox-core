from test_utils import run_query


def test___quadbin_string_toint():
    result = run_query(
        "SELECT @@RS_SCHEMA@@.__QUADBIN_STRING_TOINT('484c1fffffffffff')"
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209574053332910079
