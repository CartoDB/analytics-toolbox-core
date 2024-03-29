from test_utils import run_query


def test_quadbin_bbox():
    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_BBOX(5209574053332910079)')

    assert len(result[0]) == 1
    assert result[0][0] == '[22.5,-21.943045533438166,45.0,0.0]'
