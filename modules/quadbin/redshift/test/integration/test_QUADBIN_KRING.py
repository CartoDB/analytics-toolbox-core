from test_utils import run_query
import json


def test_quadbin_kring():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_KRING(5209574053332910079, 1) AS output"""
    )

    assert len(result[0]) == 1
    assert (
        json.loads(result[0][0]).sort()
        == [
            5208043533147045887,
            5208061125333090303,
            5208113901891223551,
            5209556461146865663,
            5209574053332910079,
            5209626829891043327,
            5209591645518954495,
            5209609237704998911,
            5209662014263132159,
        ].sort()
    )
