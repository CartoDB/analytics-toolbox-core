# Copyright (c) 2026, CARTO

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


def test_quadbin_int_tostring():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@."__QUADBIN_INT_TOSTRING"(5209574053332910079) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@."__QUADBIN_INT_TOSTRING"(0) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@."__QUADBIN_INT_TOSTRING"(NULL) FROM DUAL
        """,
        fetch=True,
    )
    assert result[0][0] == '484c1fffffffffff'
    assert result[1][0] == '0000000000000000'
    assert result[2][0] is None
