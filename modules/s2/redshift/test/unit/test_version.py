from lib import s2Lib
from lib._version import __version__


def test_init():
    assert s2Lib.__version__ == __version__
    assert hasattr(s2Lib, 'get_cell_boundary')
    assert hasattr(s2Lib, 'get_resolution')
    assert hasattr(s2Lib, 'hilbert_quadkey_to_id')
    assert hasattr(s2Lib, 'id_to_hilbert_quadkey')
    assert hasattr(s2Lib, 'int64_id_to_token')
    assert hasattr(s2Lib, 'longlat_as_int64_id')
    assert hasattr(s2Lib, 'polyfill_bbox')
    assert hasattr(s2Lib, 'token_to_int64_id')
    assert hasattr(s2Lib, 'to_children')
    assert hasattr(s2Lib, 'to_parent')
    assert hasattr(s2Lib, 'uint64_repr_from_id')
    assert hasattr(s2Lib, 'uint64_to_int64')
