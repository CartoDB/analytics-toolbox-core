import pytest
from test_utils import run_query


def index_key(item):
    return item['index']


def test_h3_kring_distances():
    """Computes kring distances for h3 and size."""
    result = run_query(
        """
            SELECT @@PG_SCHEMA@@.H3_KRING_DISTANCES('8928308280fffff', 0) as d0,
                @@PG_SCHEMA@@.H3_KRING_DISTANCES('8928308280fffff', 1) as d1,
                @@PG_SCHEMA@@.H3_KRING_DISTANCES('8928308280fffff', 2) as d2
        """
    )
    assert len(result) == 1
    assert result[0][0] == [{'index': '8928308280fffff', 'distance': 0}]
    assert sorted(result[0][1], key=index_key) == sorted(
        [
            {'index': '8928308280fffff', 'distance': 0},
            {'index': '8928308280bffff', 'distance': 1},
            {'index': '89283082873ffff', 'distance': 1},
            {'index': '89283082877ffff', 'distance': 1},
            {'index': '8928308283bffff', 'distance': 1},
            {'index': '89283082807ffff', 'distance': 1},
            {'index': '89283082803ffff', 'distance': 1},
        ],
        key=index_key,
    )
    assert sorted(result[0][2], key=index_key) == sorted(
        [
            {'index': '8928308280fffff', 'distance': 0},
            {'index': '8928308280bffff', 'distance': 1},
            {'index': '89283082873ffff', 'distance': 1},
            {'index': '89283082877ffff', 'distance': 1},
            {'index': '8928308283bffff', 'distance': 1},
            {'index': '89283082807ffff', 'distance': 1},
            {'index': '89283082803ffff', 'distance': 1},
            {'index': '8928308281bffff', 'distance': 2},
            {'index': '89283082857ffff', 'distance': 2},
            {'index': '89283082847ffff', 'distance': 2},
            {'index': '8928308287bffff', 'distance': 2},
            {'index': '89283082863ffff', 'distance': 2},
            {'index': '89283082867ffff', 'distance': 2},
            {'index': '8928308282bffff', 'distance': 2},
            {'index': '89283082823ffff', 'distance': 2},
            {'index': '89283082833ffff', 'distance': 2},
            {'index': '892830828abffff', 'distance': 2},
            {'index': '89283082817ffff', 'distance': 2},
            {'index': '89283082813ffff', 'distance': 2},
        ],
        key=index_key,
    )


def test_h3_kring_distances_fail():
    """Fails if any invalid argument."""
    with pytest.raises(Exception) as excinfo:
        run_query('SELECT @@PG_SCHEMA@@.H3_KRING_DISTANCES(NULL, NULL)')
    assert 'Invalid input size' in str(excinfo.value)

    with pytest.raises(Exception) as excinfo:
        run_query("SELECT @@PG_SCHEMA@@.H3_KRING_DISTANCES('abc', 1)")
    assert 'Invalid input origin' in str(excinfo.value)

    with pytest.raises(Exception) as excinfo:
        run_query("SELECT @@PG_SCHEMA@@.H3_KRING_DISTANCES('8928308280fffff', -1)")
    assert 'Invalid input size' in str(excinfo.value)
