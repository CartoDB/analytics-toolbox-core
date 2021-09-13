from lib import constructorsLib, __version__


def test_init():
    assert constructorsLib.__version__ == __version__
