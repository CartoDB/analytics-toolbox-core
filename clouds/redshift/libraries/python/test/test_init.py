import lib
from lib import quadbin
from lib import transformations


def test_init():
    assert hasattr(lib, '__version__')
    assert hasattr(quadbin, 'tile_to_cell')
    assert hasattr(quadbin, 'cell_to_bounding_box')
    assert hasattr(transformations, 'center_mean')
    assert hasattr(transformations, 'center_median')
    assert hasattr(transformations, 'centroid')
    assert hasattr(transformations, 'destination')
    assert hasattr(transformations, 'great_circle')
