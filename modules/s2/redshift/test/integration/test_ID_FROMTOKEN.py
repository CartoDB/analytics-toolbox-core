from test_utils import run_query

# from test_utils import run_query, redshift_connector
# import pytest


def test_id_fromtoken_success():
    results = run_query(
        """WITH context AS(
            SELECT '9' AS token UNION ALL
            SELECT '94' UNION ALL
            SELECT '93' UNION ALL
            SELECT '934' UNION ALL
            SELECT '933' UNION ALL
            SELECT '9324' UNION ALL
            SELECT '9327' UNION ALL
            SELECT '93274' UNION ALL
            SELECT '93277'
        )
        SELECT @@RS_PREFIX@@s2.ID_FROMTOKEN(token) AS id
        FROM context;"""
    )

    fixture_file = open('./test/integration/id_fromtoken_fixtures/out/ids.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


# def test_toparent_null_failure():
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.TOPARENT(NULL, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.TOPARENT(322, NULL)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
