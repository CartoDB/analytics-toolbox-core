import lib
from lib import quadbin
from lib import constructors
from lib import transformations
from lib import processing
from lib import placekey
from lib import s2


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
    assert hasattr(placekey, 'h3_is_valid')
    assert hasattr(placekey, 'placekey_to_h3')
    assert hasattr(placekey, 'h3_to_placekey')
    assert hasattr(placekey, 'placekey_is_valid')
    assert hasattr(s2, 'get_cell_boundary')
    assert hasattr(s2, 'get_resolution')
    assert hasattr(s2, 'hilbert_quadkey_to_id')
    assert hasattr(s2, 'id_to_hilbert_quadkey')
    assert hasattr(s2, 'int64_id_to_token')
    assert hasattr(s2, 'longlat_as_int64_id')
    assert hasattr(s2, 'polyfill_bbox')
    assert hasattr(s2, 'token_to_int64_id')
    assert hasattr(s2, 'to_children')
    assert hasattr(s2, 'to_parent')
    assert hasattr(s2, 'uint64_repr_from_id')
    assert hasattr(s2, 'uint64_to_int64')
