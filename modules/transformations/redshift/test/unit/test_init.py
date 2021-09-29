from lib import transformationsLib
from lib._version import __version__


def test_init():
    assert transformationsLib.__version__ == __version__
    assert hasattr(transformationsLib, 'center_mean')
    assert hasattr(transformationsLib, 'center_median')
    assert hasattr(transformationsLib, 'centroid')
    assert hasattr(transformationsLib, 'destination')
    assert hasattr(transformationsLib, 'great_circle')
