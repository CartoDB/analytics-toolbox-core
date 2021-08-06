from lib import quadkeyLib, __version__


def test_init():
    assert quadkeyLib.__version__ == __version__
