from lib import processingLib
from lib._version import __version__


def test_init():
    assert processingLib.__version__ == __version__
    assert hasattr(processingLib, 'voronoi_generic')
