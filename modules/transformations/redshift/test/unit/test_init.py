from lib import transformationsLib
from lib._version import __version__


def test_init():
    assert transformationsLib.__version__ == __version__
