from lib import placekeyLib, __version__


def test_init():
    assert placekeyLib.__version__ == __version__
