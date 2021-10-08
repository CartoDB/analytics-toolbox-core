from lib import constructorsLib
from lib._version import __version__


def test_init():
    assert constructorsLib.__version__ == __version__
    assert hasattr(constructorsLib, 'ellipse')
    assert hasattr(constructorsLib, 'bezier_spline')


def test_makeellipse():
    import geojson

    fixture_file = open(
        './test/integration/st_makeellipse_fixtures/out/geojsons.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    ellipse = constructorsLib.ellipse(
        center='{"geometry": {"type": "Point", "coordinates": [-73.9385, 40.6643]}}',
        x_semi_axis=5,
        y_semi_axis=3,
        options={'angle': -30, 'units': 'miles', 'steps': 20},
    )
    assert geojson.loads(ellipse) == geojson.loads(lines[0].rstrip())
