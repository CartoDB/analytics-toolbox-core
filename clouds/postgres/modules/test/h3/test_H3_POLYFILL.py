# flake8: noqa
import pytest
from test_utils import run_query

point = 'POINT(-3.7115216913662175 40.41092231814629)'
multi_point = 'MULTIPOINT ((-3.7115216913662175 40.41092231814629),(-3.7112427416286686 40.41200062990766),(-3.710985249563239 40.41080795073389))'
line = 'LINESTRING(-3.7142468157253483 40.40915777072141,-3.712337082906745 40.41110203797309,-3.711178368612311 40.40969694289874,-3.709290093465827 40.411396123927084)'
multi_line = 'MULTILINESTRING ((-3.7142468157253483 40.40915777072141,-3.712337082906745 40.41110203797309,-3.711178368612311 40.40969694289874,-3.709290093465827 40.411396123927084),(-3.7137572531829233 40.40860338576905,-3.7100021605620737 40.40893832932828))'
polygon = 'POLYGON ((-3.71219873428345 40.413365349070865,-3.7144088745117 40.40965661286395,-3.70659828186035 40.409525904775634,-3.71219873428345 40.413365349070865))'
multi_polygon = 'MULTIPOLYGON (((-3.7102890014648438 40.412768896581476,-3.7081432342529297 40.41124946964811,-3.707242012023926 40.41370014129302,-3.7102890014648438 40.412768896581476)),((-3.71219873428345 40.413365349070865,-3.7144088745117 40.40965661286395,-3.70659828186035 40.409525904775634,-3.71219873428345 40.413365349070865),(-3.7122470136178776 40.41158984452673,-3.710165619422321 40.41109970196702,-3.711882233191852 40.41018475963737,-3.7122470136178776 40.41158984452673)))'


@pytest.mark.parametrize(
    'name,resolution,geom,output',
    [
        ('Point', 9, point, ['89390cb1b4bffff']),
        ('MultiPoint', 9, multi_point, ['89390cb1b4bffff']),
        ('MultiPoint', 10, multi_point, ['8a390cb1b4a7fff', '8a390cb1b4b7fff']),
        (
            'MultiPoint',
            11,
            multi_point,
            ['8b390cb1b486fff', '8b390cb1b4b0fff', '8b390cb1b4a6fff'],
        ),
        ('Line', 8, line, ['88390ca349fffff', '88390cb1b5fffff']),
        (
            'Line',
            9,
            line,
            ['89390cb1b4bffff', '89390ca3497ffff'],
        ),
        (
            'Line',
            10,
            line,
            [
                '8a390cb1b487fff',
                '8a390ca3494ffff',
                '8a390cb1b497fff',
                '8a390ca3495ffff',
                '8a390ca3496ffff',
                '8a390cb1b4b7fff',
                '8a390ca34947fff',
                '8a390cb1b4affff',
            ],
        ),
        ('MultiLine', 8, multi_line, ['88390cb1b5fffff', '88390ca349fffff']),
        (
            'MultiLine',
            9,
            multi_line,
            ['89390ca3497ffff', '89390cb1b4bffff', '89390ca3487ffff'],
        ),
        (
            'Polygon',
            9,
            polygon,
            [
                '89390cb1b4fffff',
                '89390ca3497ffff',
                '89390ca34b3ffff',
                '89390cb1b4bffff',
                '89390ca3487ffff',
                '89390cb1b5bffff',
            ],
        ),
        (
            'MultiPolygon',
            9,
            multi_polygon,
            [
                '89390cb1b4bffff',
                '89390cb1b4fffff',
                '89390ca3487ffff',
                '89390cb1b5bffff',
                '89390ca34b3ffff',
                '89390cb1b43ffff',
                '89390ca3497ffff',
            ],
        ),
    ],
)
def test_h3_polyfill(name, resolution, geom, output):
    result = run_query(
        f"""
        SELECT @@PG_SCHEMA@@.H3_POLYFILL(
            ST_GEOMFROMTEXT('{geom}'), {resolution})"""
    )
    assert result[0][0] == output


@pytest.mark.parametrize(
    'name,mode,resolution,geom,output',
    [
        ('Point', 'intersects', 9, point, ['89390cb1b4bffff']),
        ('Point', 'contains', 9, point, None),
        ('Point', 'center', 9, point, None),
        (
            'Line',
            'intersects',
            8,
            line,
            ['88390ca349fffff', '88390cb1b5fffff'],
        ),
        ('Line', 'contains', 8, line, None),
        ('Line', 'center', 8, line, None),
        ('Polygon', 'wrong-mode', 4, polygon, None),
        (
            'Polygon',
            'intersects',
            9,
            polygon,
            [
                '89390cb1b4fffff',
                '89390ca3497ffff',
                '89390ca34b3ffff',
                '89390cb1b4bffff',
                '89390ca3487ffff',
                '89390cb1b5bffff',
            ],
        ),
        ('Polygon', 'contains', 10, polygon, ['8a390cb1b4b7fff', '8a390cb1b487fff']),
        (
            'Polygon',
            'center',
            9,
            polygon,
            ['89390cb1b4bffff'],
        ),
        (
            'MultiPolygon',
            'intersects',
            9,
            multi_polygon,
            [
                '89390cb1b4bffff',
                '89390cb1b4fffff',
                '89390ca3487ffff',
                '89390cb1b5bffff',
                '89390ca34b3ffff',
                '89390cb1b43ffff',
                '89390ca3497ffff',
            ],
        ),
        ('MultiPolygon', 'contains', 10, multi_polygon, None),
        (
            'MultiPolygon',
            'center',
            9,
            multi_polygon,
            ['89390cb1b4bffff'],
        ),
    ],
)
def test_h3_polyfill_mode(name, mode, resolution, geom, output):
    result = run_query(
        f"""
        SELECT @@PG_SCHEMA@@.H3_POLYFILL(
            ST_GEOMFROMTEXT('{geom}'), {resolution}, '{mode}')"""
    )
    assert result[0][0] == output
