import os
import geojson

from lib import constructors

here = os.path.dirname(__file__)


def test_ellipse():
    with open('{}/fixtures/ellipse_out.txt'.format(here), 'r') as fixture_file:
        lines = fixture_file.readlines()

    ellipse = constructors.ellipse(
        center='{"geometry": {"type": "Point", "coordinates": [-73.9385, 40.6643]}}',
        x_semi_axis=5,
        y_semi_axis=3,
        options={'angle': -30, 'units': 'miles', 'steps': 20},
    )
    assert geojson.loads(ellipse) == geojson.loads(lines[0].rstrip())
