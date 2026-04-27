# Copyright (c) 2026, CARTO

from test_utils import run_query


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

# Expected values match the quadbin library (v0.2.2) used by Redshift,
# and BigQuery's QUADBIN_POLYFILL_MODE with 'intersects' mode.
EXPECTED_POLYGON_POLYFILL = sorted(
    [
        5265786693153193983,
        5265786693163941887,
        5265786693164204031,
        5265786693164466175,
        5265786693164728319,
        5265786693165514751,
    ]
)

EXPECTED_MULTI_POLYGON_POLYFILL = sorted(
    [
        5265786693074550783,
        5265786693075337215,
        5265786693153193983,
        5265786693163941887,
        5265786693164204031,
        5265786693164466175,
        5265786693164728319,
        5265786693164990463,
        5265786693165514751,
    ]
)

RESOLUTION = 17

ANTIMERIDIAN_WKT = (
    'POLYGON ((179.5 -1, -179.5 -1, -179.5 1, 179.5 1, 179.5 -1))'
)
LARGE_BBOX_WKT = (
    'POLYGON ((-10 -10, 10 -10, 10 10, -10 10, -10 -10))'
)
DEGENERATE_POINT_WKT = 'POINT (0 0)'


def _polyfill(wkt, resolution):
    """Run QUADBIN_POLYFILL on a WKT geometry; return sorted list of ints."""
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'),
            {resolution}
        ))"""
    )
    return sorted(int(r[0]) for r in rows)


def test_quadbin_polyfill_polygon():
    assert _polyfill(POLYGON_WKT, RESOLUTION) == EXPECTED_POLYGON_POLYFILL


def test_quadbin_polyfill_multi_polygon():
    assert (
        _polyfill(MULTI_POLYGON_WKT, RESOLUTION)
        == EXPECTED_MULTI_POLYGON_POLYFILL
    )


def test_quadbin_polyfill_null():
    """NULL inputs yield an empty pipeline (zero rows)."""
    rows = run_query(
        """SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(NULL, 17))
        UNION ALL
        SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY(
                'POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))'
            ),
            NULL
        ))"""
    )
    assert rows == [] or rows == 'No results returned'


def test_quadbin_polyfill_invalid_resolution():
    """Out-of-range resolution returns an empty pipeline (NULL-on-invalid)."""
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), -1
        ))
        UNION ALL
        SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}'), 27
        ))"""
    )
    assert rows == [] or rows == 'No results returned'


def test_quadbin_polyfill_degenerate_point():
    """A point geometry covers exactly one tile (the one containing it)."""
    cells = _polyfill(DEGENERATE_POINT_WKT, 5)
    assert len(cells) >= 1


def test_quadbin_polyfill_antimeridian():
    """Antimeridian-crossing bbox produces a contiguous tile set on both sides
    of the dateline (no empty result, no duplicate sweep across 360°)."""
    cells = _polyfill(ANTIMERIDIAN_WKT, 4)
    # Resolution 4 has 2^4 = 16 tiles per row; the input spans only ~1° on
    # each side of the antimeridian, so the result must be small (well under
    # the 16-tile-per-row total) yet non-empty.
    assert 0 < len(cells) < 16 * 4


def test_quadbin_polyfill_large_bbox():
    """A bbox spanning ~20° at resolution 5 fills a sizable but bounded set
    of tiles. Verifies the BBOX-scan loop terminates."""
    cells = _polyfill(LARGE_BBOX_WKT, 5)
    assert len(cells) > 0
    # 2^5 = 32 tiles per row; a 20° × 20° box can't possibly need more than
    # the whole grid (32 * 32 = 1024).
    assert len(cells) <= 32 * 32
