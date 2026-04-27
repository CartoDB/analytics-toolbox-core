# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_string_toint():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@."__QUADBIN_STRING_TOINT"('484c1fffffffffff') FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@."__QUADBIN_STRING_TOINT"(NULL) FROM DUAL
        """,
    )
    assert result[0][0] == 5209574053332910079
    assert result[1][0] is None
