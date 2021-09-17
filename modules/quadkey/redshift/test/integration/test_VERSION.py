from test_utils import run_query
from lib import __version__


def test_version():
    result = run_query('SELECT @@RS_PREFIX@@quadkey.VERSION()')
    assert result[0][0] == __version__
