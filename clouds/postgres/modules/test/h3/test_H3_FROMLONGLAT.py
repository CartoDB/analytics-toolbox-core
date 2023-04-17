from test_utils import run_query


def test_h3_longlat():
    """Computes h3 for longitude latitude."""
    result = run_query('SELECT @@PG_SCHEMA@@.H3_FROMLONGLAT(-3.7038, 40.4168, 4)')
    assert result[0][0] == '84390cbffffffff'


def test_h3_longlat_null_input():
    """Returns null if the input is null."""
    result = run_query(
        """
      SELECT
        @@PG_SCHEMA@@.H3_FROMLONGLAT(NULL, 40.4168, 4) AS n1,
        @@PG_SCHEMA@@.H3_FROMLONGLAT(-3.7038, NULL, 4) AS n2,
        @@PG_SCHEMA@@.H3_FROMLONGLAT(-3.7038, 40.4168, NULL) AS n3
    """
    )
    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None
