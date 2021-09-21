from test_utils import run_query, redshift_connector
import pytest


def test_st_polyfill_bbox_success():
    results = run_query(
        """WITH resContext AS(
            SELECT
              -3.688531 AS min_lng,
              40.409771 AS min_lat,
              -3.680077 AS max_lng,
              40.421501 AS max_lat,
              0 AS min_res,
              30 AS max_res UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 0, 2 UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 3, 17 UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 8, 25 UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 12, 12 UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 6, 6 UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 1, 29 UNION ALL
            SELECT -3.688531, 40.409771,-3.680077, 40.421501, 4, 8
        )
        SELECT @@RS_PREFIX@@s2.ST_POLYFILL_BBOX(min_lng, min_lat, max_lng, max_lat, min_res, max_res) as ids
            FROM resContext;"""
    )

    fixture_file = open(
        './test/integration/st_polyfill_bbox_fixtures/out/ids.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_st_polyfill_bbox_invalid_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.ST_POLYFILL_BBOX(-3.688531, 40.409771,-3.680077, 40.421501, -1, 2)')
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.ST_POLYFILL_BBOX(-3.688531, 40.409771,-3.680077, 40.421501, 0, 31)')
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.ST_POLYFILL_BBOX(-3.688531, 40.409771,-3.680077, 40.421501, 8, 3)')
    assert 'InvalidResolution' in str(excinfo.value)


# def test_longlat_asquadint_null_failure():
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASID(NULL, 10, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASID(10, NULL, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASID(10, 10, NULL)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
