from test_utils import run_query

exec(open('./lib/_version.py').read())


def test_version():
    result = run_query('SELECT @@RS_PREFIX@@processing.VERSION()')
    assert result[0][0] == __version__  # noqa
