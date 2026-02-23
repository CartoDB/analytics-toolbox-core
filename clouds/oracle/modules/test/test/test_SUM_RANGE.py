import pytest

from test_utils import run_query, DatabaseError


def test_sum_range_success():
    """Test SUM_RANGE function with valid inputs."""
    result = run_query(
        """SELECT @@ORA_SCHEMA@@.SUM_RANGE(1, 5) as result1,
                  @@ORA_SCHEMA@@.SUM_RANGE(1, 10) as result2,
                  @@ORA_SCHEMA@@.SUM_RANGE(5, 5) as result3,
                  @@ORA_SCHEMA@@.SUM_RANGE(0, 0) as result4
           FROM DUAL"""
    )

    # SUM_RANGE(1, 5) = 1+2+3+4+5 = 15
    assert result[0][0] == 15
    # SUM_RANGE(1, 10) = 1+2+3+4+5+6+7+8+9+10 = 55
    assert result[0][1] == 55
    # SUM_RANGE(5, 5) = 5
    assert result[0][2] == 5
    # SUM_RANGE(0, 0) = 0
    assert result[0][3] == 0


def test_sum_range_negative():
    """Test SUM_RANGE with negative numbers."""
    result = run_query(
        """SELECT @@ORA_SCHEMA@@.SUM_RANGE(-3, 3) as result
           FROM DUAL"""
    )

    # SUM_RANGE(-3, 3) = -3 + -2 + -1 + 0 + 1 + 2 + 3 = 0
    assert result[0][0] == 0


def test_sum_range_depends_on_add_one():
    """Verify SUM_RANGE was deployed after ADD_ONE (dependency order)."""
    # This test verifies that SUM_RANGE can call ADD_ONE
    # If deployment order was wrong, this would fail
    result = run_query(
        """SELECT @@ORA_SCHEMA@@.SUM_RANGE(10, 12) as result
           FROM DUAL"""
    )

    # SUM_RANGE(10, 12) = 10 + 11 + 12 = 33
    assert result[0][0] == 33
