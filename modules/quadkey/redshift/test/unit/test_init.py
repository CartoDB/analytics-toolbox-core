from lib import quadkeyLib
from lib._version import __version__


def test_init():
    assert quadkeyLib.__version__ == __version__
