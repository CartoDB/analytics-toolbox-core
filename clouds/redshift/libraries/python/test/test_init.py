import lib
from lib import quadbin
from lib import constructors
from lib import transformations
from lib import processing


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
    assert hasattr(constructors, 'bezier_spline')
    assert hasattr(constructors, 'ellipse')
    assert hasattr(transformations, 'center_mean')
    assert hasattr(transformations, 'center_median')
    assert hasattr(transformations, 'centroid')
    assert hasattr(transformations, 'destination')
    assert hasattr(transformations, 'great_circle')
    assert hasattr(processing, 'voronoi_generic')
