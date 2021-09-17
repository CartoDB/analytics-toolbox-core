from lib import constructorsLib
from lib._version import __version__


def test_init():
    assert constructorsLib.__version__ == __version__
