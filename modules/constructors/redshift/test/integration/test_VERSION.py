from lib._version import __version__
from test_utils import run_query


def test_version():
    result = run_query('SELECT @@RS_PREFIX@@constructors.VERSION()')
    assert result[0][0] == __version__
