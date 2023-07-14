import pytest
from test_utils import run_query

children = [
    (
        5209574053332910079,
        5,
        [
            5214064458820747263,
            5214068856867258367,
            5214073254913769471,
            5214077652960280575,
        ],
    ),
    (
        5209574053332910079,
        6,
        [
            5218564759913234431,
            5218565859424862207,
            5218566958936489983,
            5218568058448117759,
            5218569157959745535,
            5218570257471373311,
            5218571356983001087,
            5218572456494628863,
            5218573556006256639,
            5218574655517884415,
            5218575755029512191,
            5218576854541139967,
            5218577954052767743,
            5218579053564395519,
            5218580153076023295,
            5218581252587651071,
        ],
    ),
]


@pytest.mark.parametrize('quadbin, resolution, children', children)
def test_quadbin_tochildren(quadbin, resolution, children):
    """Computes children for quadbin."""
    result = run_query(
        f'SELECT @@PG_SCHEMA@@.QUADBIN_TOCHILDREN({quadbin},{resolution})'
    )
    assert result[0][0] == children


def test_quadbin_tochildren_neg_res():
    """Throws error for negative resolution."""
    with pytest.raises(Exception):
        run_query('SELECT @@PG_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, -1)')


def test_quadbin_tochildren_overflow_res():
    """Throws error for resolution overflow."""
    with pytest.raises(Exception):
        run_query('SELECT @@PG_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, 27)')


def test_quadbin_toparent_small_res():
    """Throws error for resolution smaller than the index."""
    with pytest.raises(Exception):
        run_query('SELECT @@PG_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, 3)')
