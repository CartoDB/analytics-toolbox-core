# Copyright (c) 2026, CARTO

import pytest

from test_utils import run_query


# Fixtures aligned with BigQuery and Postgres test fixtures verbatim.
# QUADBIN_POLYFILL is a faithful port of the BigQuery / Postgres algorithm:
# default mode 'center' returns 3 cells, mode 'intersects' returns 6, etc.
POINT = 'POINT(-3.7115216913662175 40.41092231814629)'
MULTI_POINT = (
    'MULTIPOINT ((-3.7115216913662175 40.41092231814629),'
    '(-3.7112427416286686 40.41200062990766),'
    '(-3.710985249563239 40.41080795073389))'
)
LINE = (
    'LINESTRING(-3.7142468157253483 40.40915777072141,'
    '-3.712337082906745 40.41110203797309,'
    '-3.711178368612311 40.40969694289874,'
    '-3.709290093465827 40.411396123927084)'
)
MULTI_LINE = (
    'MULTILINESTRING ((-3.7142468157253483 40.40915777072141,'
    '-3.712337082906745 40.41110203797309,'
    '-3.711178368612311 40.40969694289874,'
    '-3.709290093465827 40.411396123927084),'
    '(-3.7137572531829233 40.40860338576905,'
    '-3.7100021605620737 40.40893832932828))'
)
POLYGON = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)
MULTI_POLYGON = (
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


def _polyfill(wkt, resolution, mode=None):
    """Return sorted list of quadbin indices."""
    if mode is None:
        sql = f"""SELECT COLUMN_VALUE
            FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
                SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'),
                {resolution}
            ))"""
    else:
        sql = f"""SELECT COLUMN_VALUE
            FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
                SDO_UTIL.FROM_WKTGEOMETRY('{wkt}'),
                {resolution},
                '{mode}'
            ))"""
    rows = run_query(sql)
    if rows == 'No results returned' or rows is None:
        return []
    return sorted(int(r[0]) for r in rows)


# ----------------------------------------------------------------------
# Default form: QUADBIN_POLYFILL(geom, resolution) — defaults to 'center'
# Fixtures match BigQuery and Postgres exactly.
# ----------------------------------------------------------------------
@pytest.mark.parametrize(
    'name,resolution,wkt,output',
    [
        ('Point', 17, POINT, []),
        ('Line', 15, LINE, []),
        (
            'Polygon',
            17,
            POLYGON,
            [5265786693163941887, 5265786693164466175, 5265786693164728319],
        ),
        (
            'MultiPolygon',
            17,
            MULTI_POLYGON,
            [
                5265786693163941887,
                5265786693164204031,
                5265786693164466175,
                5265786693164728319,
            ],
        ),
    ],
)
def test_quadbin_polyfill_default_center(name, resolution, wkt, output):
    assert _polyfill(wkt, resolution) == sorted(output)


# ----------------------------------------------------------------------
# Mode form: QUADBIN_POLYFILL(geom, resolution, mode)
# Fixtures match BigQuery's QUADBIN_POLYFILL_MODE and Postgres's 3-arg form.
# ----------------------------------------------------------------------
@pytest.mark.parametrize(
    'name,mode,resolution,wkt,output',
    [
        ('Point', 'center', 17, POINT, []),
        ('Point', 'contains', 17, POINT, []),
        ('Point', 'intersects', 17, POINT, [5265786693164466175]),
        ('MultiPoint', 'intersects', 16, MULTI_POINT, [5261283093537357823]),
        (
            'MultiPoint',
            'intersects',
            17,
            MULTI_POINT,
            [5265786693163941887, 5265786693164466175],
        ),
        (
            'MultiPoint',
            'intersects',
            19,
            MULTI_POINT,
            [5274793892418650111, 5274793892419026943, 5274793892419076095],
        ),
        ('Line', 'center', 15, LINE, []),
        ('Line', 'contains', 15, LINE, []),
        (
            'Line',
            'intersects',
            15,
            LINE,
            [5256779493900550143, 5256779493913133055],
        ),
        (
            'Line',
            'intersects',
            17,
            LINE,
            [
                5265786693153193983,
                5265786693154766847,
                5265786693164466175,
                5265786693164728319,
            ],
        ),
        (
            'MultiLine',
            'intersects',
            15,
            MULTI_LINE,
            [5256779493900550143, 5256779493913133055],
        ),
        (
            'MultiLine',
            'intersects',
            17,
            MULTI_LINE,
            [
                5265786693153193983,
                5265786693154766847,
                5265786693164466175,
                5265786693164728319,
                5265786693166039039,
                5265786693166301183,
            ],
        ),
        ('Polygon', 'wrong-mode', 17, POLYGON, []),
        (
            'Polygon',
            'center',
            17,
            POLYGON,
            [5265786693163941887, 5265786693164466175, 5265786693164728319],
        ),
        ('Polygon', 'contains', 18, POLYGON, [5270290292791705599]),
        (
            'Polygon',
            'intersects',
            17,
            POLYGON,
            [
                5265786693153193983,
                5265786693163941887,
                5265786693164204031,
                5265786693164466175,
                5265786693164728319,
                5265786693165514751,
            ],
        ),
        (
            'MultiPolygon',
            'center',
            17,
            MULTI_POLYGON,
            [
                5265786693163941887,
                5265786693164204031,
                5265786693164466175,
                5265786693164728319,
            ],
        ),
        ('MultiPolygon', 'contains', 18, MULTI_POLYGON, []),
        (
            'MultiPolygon',
            'intersects',
            17,
            MULTI_POLYGON,
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
            ],
        ),
    ],
)
def test_quadbin_polyfill_mode(name, mode, resolution, wkt, output):
    assert _polyfill(wkt, resolution, mode) == sorted(output)


# ----------------------------------------------------------------------
# NULL / invalid-resolution: empty pipeline (Oracle NULL-on-invalid convention)
# ----------------------------------------------------------------------
def test_quadbin_polyfill_null_geom():
    rows = run_query(
        """SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(NULL, 17))"""
    )
    assert rows == 'No results returned' or rows == [] or rows is None


def test_quadbin_polyfill_null_resolution():
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON}'), NULL
        ))"""
    )
    assert rows == 'No results returned' or rows == [] or rows is None


@pytest.mark.parametrize('resolution', [-1, 27])
def test_quadbin_polyfill_invalid_resolution(resolution):
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
            SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON}'), {resolution}
        ))"""
    )
    assert rows == 'No results returned' or rows == [] or rows is None
