import pytest
from test_utils import run_query


def test_h3_kring():
    """Computes kring for h3 and size."""
    result = run_query(
        """
            SELECT @@PG_SCHEMA@@.H3_KRING('8928308280fffff', 0) as d0,
                @@PG_SCHEMA@@.H3_KRING('8928308280fffff', 1) as d1,
                @@PG_SCHEMA@@.H3_KRING('8928308280fffff', 2) as d2
        """
    )
    assert len(result) == 1
    assert result[0][0] == ['8928308280fffff']
    assert sorted(result[0][1]) == sorted(
        [
            '8928308280fffff',
            '8928308280bffff',
            '89283082873ffff',
            '89283082877ffff',
            '8928308283bffff',
            '89283082807ffff',
            '89283082803ffff',
        ]
    )
    assert sorted(result[0][2]) == sorted(
        [
            '8928308280fffff',
            '8928308280bffff',
            '89283082873ffff',
            '89283082877ffff',
            '8928308283bffff',
            '89283082807ffff',
            '89283082803ffff',
            '8928308281bffff',
            '89283082857ffff',
            '89283082847ffff',
            '8928308287bffff',
            '89283082863ffff',
            '89283082867ffff',
            '8928308282bffff',
            '89283082823ffff',
            '89283082833ffff',
            '892830828abffff',
            '89283082817ffff',
            '89283082813ffff',
        ]
    )


def test_h3_kring_fail():
    """Fails if any invalid argument."""
    with pytest.raises(Exception) as excinfo:
        run_query('SELECT @@PG_SCHEMA@@.H3_KRING(NULL, NULL)')
    assert 'Invalid input size' in str(excinfo.value)

    with pytest.raises(Exception) as excinfo:
        run_query("SELECT @@PG_SCHEMA@@.H3_KRING('abc', 1)")
    assert 'Invalid input origin' in str(excinfo.value)

    with pytest.raises(Exception) as excinfo:
        run_query("SELECT @@PG_SCHEMA@@.H3_KRING('8928308280fffff', -1)")
    assert 'Invalid input size' in str(excinfo.value)
