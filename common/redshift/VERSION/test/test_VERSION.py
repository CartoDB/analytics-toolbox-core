from test_utils import run_query


def test_version():
    result = run_query('SELECT @@RS_PREFIX@@carto.VERSION()')
    assert result[0][0] == '1.0.0'
