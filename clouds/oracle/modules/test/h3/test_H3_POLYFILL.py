# Copyright (c) 2026, CARTO
import json
from test_utils import run_query


# Test geometries (WKT)
POLYGON_WKT = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)

MULTI_POLYGON_WKT = (
    'MULTIPOLYGON (((-3.7102890014648438 40.412768896581476,'
    '-3.7081432342529297 40.41124946964811,'
    '-3.707242012023926 40.41370014129302,'
    '-3.7102890014648438 40.412768896581476)),'
    '((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865),'
    '(-3.7122470136178776 40.41158984452673,'
    '-3.710165619422321 40.41109970196702,'
    '-3.711882233191852 40.41018475963737,'
    '-3.7122470136178776 40.41158984452673)))'
)

POINT_WKT = 'POINT(-3.7115216913662175 40.41092231814629)'

LINE_WKT = (
    'LINESTRING(-3.7142468157253483 40.40915777072141,'
    '-3.712337082906745 40.41110203797309,'
    '-3.711178368612311 40.40969694289874,'
    '-3.709290093465827 40.411396123927084)'
)


def _polyfill_query(wkt, resolution):
    """Build a polyfill query from WKT and resolution."""
    return (
        f"SELECT @@ORA_SCHEMA@@.H3_POLYFILL("
        f"SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'), {resolution}) FROM DUAL"
    )


def test_h3_polyfill_polygon_center():
    """Polygon at resolution 9 returns expected cells (center mode)."""
    result = run_query(_polyfill_query(POLYGON_WKT, 9))
    assert len(result) == 1
    cells = json.loads(result[0][0])
    assert sorted(cells) == ['89390cb1b4bffff']


def test_h3_polyfill_multipolygon_center():
    """MultiPolygon at resolution 9 returns expected cells (center mode)."""
    result = run_query(_polyfill_query(MULTI_POLYGON_WKT, 9))
    assert len(result) == 1
    cells = json.loads(result[0][0])
    assert sorted(cells) == ['89390cb1b4bffff']


def test_h3_polyfill_point_returns_null():
    """Point geometry returns NULL (non-polygon)."""
    result = run_query(_polyfill_query(POINT_WKT, 9))
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_polyfill_line_returns_null():
    """Linestring geometry returns NULL (non-polygon)."""
    result = run_query(_polyfill_query(LINE_WKT, 8))
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_polyfill_null_geom():
    """NULL geometry returns NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_POLYFILL(NULL, 9) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_polyfill_null_resolution():
    """NULL resolution returns NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_POLYFILL("
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), NULL) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_polyfill_all_valid():
    """All returned cells should be valid H3 indexes."""
    result = run_query(_polyfill_query(POLYGON_WKT, 9))
    cells = json.loads(result[0][0])
    for cell in cells:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{cell}') FROM DUAL"
        )
        assert valid_result[0][0] == 1, f'Cell {cell} is not valid'


def test_h3_polyfill_all_correct_resolution():
    """All returned cells should have the requested resolution."""
    target_res = 9
    result = run_query(_polyfill_query(POLYGON_WKT, target_res))
    cells = json.loads(result[0][0])
    for cell in cells:
        res_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('{cell}') FROM DUAL"
        )
        assert res_result[0][0] == target_res, (
            f'Cell {cell} has resolution {res_result[0][0]}, '
            f'expected {target_res}'
        )


def test_h3_polyfill_unique_cells():
    """All returned cells should be unique."""
    result = run_query(_polyfill_query(POLYGON_WKT, 9))
    cells = json.loads(result[0][0])
    assert len(cells) == len(set(cells))


def test_h3_polyfill_resolution_out_of_range():
    """Resolution outside 0-15 returns NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_POLYFILL("
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), -1) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None

    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_POLYFILL("
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), 16) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_polyfill_sorted_output():
    """Returned JSON array should be sorted."""
    result = run_query(_polyfill_query(POLYGON_WKT, 9))
    cells = json.loads(result[0][0])
    assert cells == sorted(cells)
