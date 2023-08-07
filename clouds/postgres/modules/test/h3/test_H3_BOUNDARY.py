from test_utils import run_query


def test_h3_boundary():
    """Computes boundary for h3."""
    result = run_query(
        """
        SELECT ST_EQUALS(
            @@PG_SCHEMA@@.H3_BOUNDARY('84390cbffffffff'),
            ST_GEOMFROMTEXT('SRID=4326;POLYGON((-3.576927435395731 40.613438595935165,-3.85975632308016 40.525472355369885,-3.899552298996668 40.28411330409504,-3.658026640031941 40.131404681000596,-3.376968454311584 40.2193743440867,-3.335672466641674 40.46004784506314,-3.576927435395731 40.613438595935165))')
        )
        """  # noqa
    )
    assert len(result) == 1


def test_h3_boundary_null_input():
    """Returns null if the input is null."""
    result = run_query('SELECT @@PG_SCHEMA@@.H3_BOUNDARY(NULL)')
    assert result[0][0] is None
