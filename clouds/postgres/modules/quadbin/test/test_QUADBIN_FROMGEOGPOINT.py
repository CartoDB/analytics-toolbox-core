from test_utils import run_query


def test_quadbin_fromgeogpoint_no_srid():
    """Computes quadbin for point with no SRID."""
    result = run_query(
        'SELECT @@PG_SCHEMA@@.QUADBIN_FROMGEOGPOINT(ST_MAKEPOINT(40.4168, -3.7038), 4)'
    )
    assert result[0][0] == 5209574053332910079


def test_quadbin_fromgeogpoint_4326_srid():
    """Computes quadbin for point with 4326 SRID."""
    result = run_query(
        """
        SELECT @@PG_SCHEMA@@.QUADBIN_FROMGEOGPOINT(
            ST_SETSRID(ST_MAKEPOINT(40.4168, -3.7038), 4326), 4)
    """
    )
    assert result[0][0] == 5209574053332910079


def test_quadbin_fromgeogpoint_other_srid():
    """Computes quadbin for point with other SRID."""
    result = run_query(
        """
        SELECT @@PG_SCHEMA@@.QUADBIN_FROMGEOGPOINT(ST_SETSRID(
            ST_MAKEPOINT(6827983.210245196, 9369020.020647347), 32729), 4)
    """
    )
    assert result[0][0] == 5209574053332910079
