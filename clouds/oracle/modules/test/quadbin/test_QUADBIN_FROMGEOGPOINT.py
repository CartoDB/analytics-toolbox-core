# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromgeogpoint():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT(
            SDO_GEOMETRY(2001, 4326,
                SDO_POINT_TYPE(40.4168, -3.7038, NULL),
                NULL, NULL),
            4
        ) FROM DUAL
        """,
    )
    assert result[0][0] == 5209574053332910079


def test_quadbin_fromgeogpoint_null():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT(NULL, 4) FROM DUAL
        """,
    )
    assert result[0][0] is None

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT(
            SDO_GEOMETRY(2001, 4326,
                SDO_POINT_TYPE(40.4168, -3.7038, NULL),
                NULL, NULL),
            NULL
        ) FROM DUAL
        """,
    )
    assert result[0][0] is None
