from lib import quadkeyLib
from lib._version import __version__


def test_init():
    assert quadkeyLib.__version__ == __version__
    assert hasattr(quadkeyLib, 'quadint_from_zxy')
    assert hasattr(quadkeyLib, 'zxy_from_quadint')
    assert hasattr(quadkeyLib, 'sibling')
    assert hasattr(quadkeyLib, 'to_children')
    assert hasattr(quadkeyLib, 'to_parent')
    assert hasattr(quadkeyLib, 'kring')
    assert hasattr(quadkeyLib, 'kring_distances')
    assert hasattr(quadkeyLib, 'quadint_from_location')
    assert hasattr(quadkeyLib, 'quadint_from_quadkey')
    assert hasattr(quadkeyLib, 'quadkey_from_quadint')
    assert hasattr(quadkeyLib, 'bbox')
    assert hasattr(quadkeyLib, 'quadint_to_geojson')
    assert hasattr(quadkeyLib, 'clip_number')
    assert hasattr(quadkeyLib, 'geojson_to_quadints')
