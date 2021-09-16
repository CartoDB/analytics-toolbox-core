from test_utils import run_query

# from test_utils import run_query, redshift_connector
# import pytest


def test_uint64_from_id_success():
    results = run_query(
        """WITH context AS(
            SELECT -8070450532247928832 AS id UNION ALL
            SELECT -7782220156096217088 UNION ALL
            SELECT -7854277750134145024 UNION ALL
            SELECT -7836263351624663040 UNION ALL
            SELECT -7840766951252033536 UNION ALL
            SELECT -7844144650972561408 UNION ALL
            SELECT -7843300226042429440 UNION ALL
            SELECT -7843229857298251776 UNION ALL
            SELECT -7843177080740118528
        )
        SELECT @@RS_PREFIX@@s2.UINT64REPR_FROM_ID(id) AS token
        FROM context;"""
    )

    fixture_file = open(
        './test/integration/uint64repr_from_id_fixtures/out/uint64_ids.txt', 'r'
    )
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
