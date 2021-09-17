from test_utils import run_query

# Initialize variable just to avoid linter complaints
__version__ = None
exec(open('./lib/version.py').read())


def test_version():
    result = run_query('SELECT @@RS_PREFIX@@s2.VERSION()')
    assert result[0][0] == __version__
