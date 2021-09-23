from lib import placekeyLib
from lib._version import __version__


def test_init():
    assert placekeyLib.__version__ == __version__
    assert hasattr(placekeyLib, 'h3_is_valid')
    assert hasattr(placekeyLib, 'placekey_to_h3')
    assert hasattr(placekeyLib, 'h3_to_placekey')
    assert hasattr(placekeyLib, 'placekey_is_valid')
