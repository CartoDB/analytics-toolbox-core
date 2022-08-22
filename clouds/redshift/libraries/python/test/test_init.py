import lib
from lib import quadbin


def test_init():
    assert hasattr(lib, '__version__')
    assert hasattr(quadbin, 'tile_to_cell')
    assert hasattr(quadbin, 'cell_to_bounding_box')
    assert hasattr(quadbin, 'cell_to_boundary')
    assert hasattr(quadbin, 'cell_to_point')
    assert hasattr(quadbin, 'point_to_cell')
    assert hasattr(quadbin, 'is_valid_cell')
    assert hasattr(quadbin, 'k_ring_distances')
    assert hasattr(quadbin, 'k_ring')
    assert hasattr(quadbin, 'geometry_to_cells')
    assert hasattr(quadbin, 'cell_sibling')
    assert hasattr(quadbin, 'cell_to_children')
