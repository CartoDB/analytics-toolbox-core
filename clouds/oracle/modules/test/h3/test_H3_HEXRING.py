# Copyright (c) 2026, CARTO
import json
import pytest
from test_utils import run_query


def test_h3_hexring_distance_0():
    """Hex ring with distance 0 returns only the origin."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', 0) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    assert sorted(cells) == ['8928308280fffff']


def test_h3_hexring_distance_1():
    """Hex ring with distance 1 returns 6 neighbors (NOT including center)."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', 1) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    expected = [
        '89283082803ffff',
        '89283082807ffff',
        '8928308280bffff',
        '89283082873ffff',
        '89283082877ffff',
        '8928308283bffff',
    ]
    assert sorted(cells) == sorted(expected)


def test_h3_hexring_distance_2():
    """Hex ring with distance 2 returns 12 cells on the outer ring only."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', 2) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    expected = [
        '89283082813ffff',
        '89283082817ffff',
        '8928308281bffff',
        '89283082823ffff',
        '8928308282bffff',
        '89283082833ffff',
        '89283082847ffff',
        '89283082857ffff',
        '89283082863ffff',
        '89283082867ffff',
        '8928308287bffff',
        '892830828abffff',
    ]
    assert sorted(cells) == sorted(expected)


def test_h3_hexring_all_unique():
    """All cells in the hex ring result should be unique."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', 2) FROM DUAL"
    )
    cells = json.loads(result[0][0])
    assert len(cells) == len(set(cells))


def test_h3_hexring_all_valid():
    """All cells in the hex ring result should be valid H3 indexes."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', 1) FROM DUAL"
    )
    cells = json.loads(result[0][0])
    for cell in cells:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{cell}') FROM DUAL"
        )
        assert valid_result[0][0] == 1, f'Cell {cell} is not valid'


def test_h3_hexring_null_origin():
    """Raises error when origin is NULL."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            'SELECT @@ORA_SCHEMA@@.H3_HEXRING(NULL, 1) FROM DUAL'
        )
    assert 'Invalid input origin' in str(excinfo.value)


def test_h3_hexring_invalid_origin():
    """Raises error when origin is not a valid H3 index."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            "SELECT @@ORA_SCHEMA@@.H3_HEXRING('abc', 1) FROM DUAL"
        )
    assert 'Invalid input origin' in str(excinfo.value)


def test_h3_hexring_null_size():
    """Raises error when size is NULL."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', NULL)"
            " FROM DUAL"
        )
    assert 'Invalid input size' in str(excinfo.value)


def test_h3_hexring_negative_size():
    """Raises error when size is negative."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            "SELECT @@ORA_SCHEMA@@.H3_HEXRING('8928308280fffff', -1)"
            " FROM DUAL"
        )
    assert 'Invalid input size' in str(excinfo.value)
