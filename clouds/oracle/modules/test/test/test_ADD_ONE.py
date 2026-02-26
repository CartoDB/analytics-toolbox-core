from test_utils import run_query


def test_add_one_success():
    """Test ADD_ONE function with valid inputs."""
    result = run_query(
        """SELECT @@ORA_SCHEMA@@.ADD_ONE(1) as result1,
                  @@ORA_SCHEMA@@.ADD_ONE(5) as result2,
                  @@ORA_SCHEMA@@.ADD_ONE(100) as result3,
                  @@ORA_SCHEMA@@.ADD_ONE(-10) as result4
           FROM DUAL"""
    )

    assert result[0][0] == 2
    assert result[0][1] == 6
    assert result[0][2] == 101
    assert result[0][3] == -9


def test_add_one_null():
    """Test ADD_ONE function with NULL input."""
    result = run_query('SELECT @@ORA_SCHEMA@@.ADD_ONE(NULL) FROM DUAL')
    assert result[0][0] is None
