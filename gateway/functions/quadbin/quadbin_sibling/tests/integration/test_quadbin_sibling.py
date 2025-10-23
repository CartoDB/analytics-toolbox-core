"""Integration tests for QUADBIN_SIBLING function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinSiblingIntegration:
    """Integration tests for QUADBIN_SIBLING with Redshift"""

    def test_quadbin_sibling_up(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'up')"
        )

        assert len(result[0]) == 1
        assert result[0][0] == 5208061125333090303

    def test_quadbin_sibling_down(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'down')"
        )

        assert len(result[0]) == 1
        assert result[0][0] == 5209609237704998911

    def test_quadbin_sibling_left(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'left')"
        )

        assert len(result[0]) == 1
        assert result[0][0] == 5209556461146865663

    def test_quadbin_sibling_right(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'right')"
        )

        assert len(result[0]) == 1
        assert result[0][0] == 5209626829891043327

    def test_quadbin_sibling_none(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5192650370358181887, 'up')"
        )

        assert len(result[0]) == 1
        assert result[0][0] is None

    def test_quadbin_sibling_failure(self):
        error = "Wrong direction argument passed to sibling"
        with pytest.raises(Exception, match=error):
            run_query(
                "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'wrong')"
            )
