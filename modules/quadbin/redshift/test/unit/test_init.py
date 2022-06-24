from lib import quadbinLib
from lib._version import __version__


def test_init():
    assert quadbinLib.__version__ == __version__
    assert hasattr(quadbinLib, 'quadbin_from_zxy')
    assert hasattr(quadbinLib, 'quadbin_to_zxy')
    assert hasattr(quadbinLib, 'sibling')
    assert hasattr(quadbinLib, 'to_children')
    assert hasattr(quadbinLib, 'kring')
    assert hasattr(quadbinLib, 'kring_distances')
    assert hasattr(quadbinLib, 'quadbin_from_location')
    assert hasattr(quadbinLib, 'quadbin_center')
    assert hasattr(quadbinLib, 'bbox')
    assert hasattr(quadbinLib, 'quadbin_to_geojson')
    assert hasattr(quadbinLib, 'clip_number')
    assert hasattr(quadbinLib, 'geojson_to_quadbins')
