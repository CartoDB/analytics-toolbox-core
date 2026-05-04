# Copyright (c) 2026, CARTO
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


def _polyfill(wkt, resolution):
    """Run H3_POLYFILL as a TABLE and return the list of cells."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_POLYFILL('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'), {resolution}))"
    )
    return [r[0] for r in run_query(sql)]


def test_h3_polyfill_polygon_center():
    """Polygon at resolution 9 returns expected cells (center mode)."""
    assert sorted(_polyfill(POLYGON_WKT, 9)) == ['89390cb1b4bffff']


def test_h3_polyfill_multipolygon_center():
    """MultiPolygon at resolution 9 returns expected cells (center mode)."""
    assert sorted(_polyfill(MULTI_POLYGON_WKT, 9)) == ['89390cb1b4bffff']


def test_h3_polyfill_point_returns_empty():
    """Point geometry returns no rows (non-polygon)."""
    assert _polyfill(POINT_WKT, 9) == []


def test_h3_polyfill_line_returns_empty():
    """Linestring geometry returns no rows (non-polygon)."""
    assert _polyfill(LINE_WKT, 8) == []


def test_h3_polyfill_null_geom():
    """NULL geometry returns no rows."""
    sql = 'SELECT COLUMN_VALUE FROM TABLE(' '@@ORA_SCHEMA@@.H3_POLYFILL(NULL, 9))'
    assert run_query(sql) == []


def test_h3_polyfill_null_resolution():
    """NULL resolution returns no rows."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_POLYFILL('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), NULL))"
    )
    assert run_query(sql) == []


def test_h3_polyfill_all_valid():
    """All returned cells should be valid H3 indexes."""
    invalid = run_query(
        f'SELECT t.COLUMN_VALUE AS h3'
        f' FROM TABLE(@@ORA_SCHEMA@@.H3_POLYFILL('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), 9)) t"
        f' WHERE @@ORA_SCHEMA@@.H3_ISVALID(t.COLUMN_VALUE) != 1'
    )
    assert (
        invalid == 'No results returned' or invalid == []
    ), f'Invalid cells in polyfill: {invalid}'


def test_h3_polyfill_all_correct_resolution():
    """All returned cells should have the requested resolution."""
    target_res = 9
    wrong_res = run_query(
        f'SELECT t.COLUMN_VALUE AS h3'
        f' FROM TABLE(@@ORA_SCHEMA@@.H3_POLYFILL('
        f"SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), {target_res})) t"
        f' WHERE @@ORA_SCHEMA@@.H3_RESOLUTION(t.COLUMN_VALUE) != {target_res}'
    )
    assert (
        wrong_res == 'No results returned' or wrong_res == []
    ), f'Cells at wrong resolution: {wrong_res}'


def test_h3_polyfill_unique_cells():
    """All returned cells should be unique."""
    cells = _polyfill(POLYGON_WKT, 9)
    assert len(cells) == len(set(cells))


def test_h3_polyfill_resolution_out_of_range():
    """Resolution outside 0-15 returns no rows."""
    assert _polyfill(POLYGON_WKT, -1) == []
    assert _polyfill(POLYGON_WKT, 16) == []


def test_h3_polyfill_sorted_output():
    """Returned rows should be in lexicographic order."""
    cells = _polyfill(POLYGON_WKT, 9)
    assert cells == sorted(cells)
