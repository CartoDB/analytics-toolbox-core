from python_utils.run_query import run_query


def test_version_core_success():
    query = 'SELECT @@DB_SCHEMA@@.VERSION_CORE();'
    result = run_query(query)
    assert result[0][0] == '0.1.0'
