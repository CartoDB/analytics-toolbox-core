from lib import s2Lib, __version__


def test_init():
    assert s2Lib.__version__ == __version__
    assert hasattr(s2Lib, 'get_cell_boundary')
    assert hasattr(s2Lib, 'get_resolution')
    assert hasattr(s2Lib, 'longlat_as_int64_id')
    assert hasattr(s2Lib, 'int64_id_to_token')
    assert hasattr(s2Lib, 'to_children')
    assert hasattr(s2Lib, 'to_parent')
    assert hasattr(s2Lib, 'uint64_repr_from_id')
