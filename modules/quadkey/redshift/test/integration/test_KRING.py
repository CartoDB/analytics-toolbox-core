from test_utils import run_query, redshift_connector
import pytest


def test_kring_success():
    result = run_query(
        'SELECT @@RS_PREFIX@@quadkey.KRING(162, 1) as kring1, '
        '@@RS_PREFIX@@quadkey.KRING(12070922, 1) as kring2, '
        '@@RS_PREFIX@@quadkey.KRING(791040491538, 1) as kring3, '
        '@@RS_PREFIX@@quadkey.KRING(12960460429066265, NULL) as kring4, '
        '@@RS_PREFIX@@quadkey.KRING(12070922, 2) as kring5, '
        '@@RS_PREFIX@@quadkey.KRING(791040491538, 3) as kring6')

    assert result[0][0] == str(sorted([130, 162, 194, 2, 258, 290, 322, 34, 66])).replace(' ','')
    assert result[0][1] == str(sorted([12038122, 12038154, 12038186, 12070890, 12070922, 12070954, 12103658, 12103690, 12103722])).replace(' ','')
    assert result[0][2] == str(sorted([791032102898, 791032102930, 791032102962, 791040491506, 791040491538, 791040491570, 791048880114, 791048880146, 791048880178])).replace(' ','')
    assert result[0][3] == str(sorted([12960459355324409, 12960459355324441, 12960459355324473, 12960460429066233, 12960460429066265, 12960460429066297, 12960461502808057, 12960461502808089, 12960461502808121])).replace(' ','')
    assert result[0][4] == str(sorted([12005322, 12005354, 12005386, 12005418, 12005450, 12038090, 12038122, 12038154, 12038186, 12038218, 12070858, 12070890, 12070922, 12070954, 12070986, 12103626, 12103658, 12103690, 12103722, 12103754, 12136394, 12136426, 12136458, 12136490, 12136522])).replace(' ','')
    assert result[0][5] == str(sorted([791015325618, 791015325650, 791015325682, 791015325714, 791015325746, 791015325778, 791015325810, 791023714226, 791023714258, 791023714290, 791023714322, 791023714354, 791023714386, 791023714418, 791032102834, 791032102866, 791032102898, 791032102930, 791032102962, 791032102994, 791032103026, 791040491442, 791040491474, 791040491506, 791040491538, 791040491570, 791040491602, 791040491634, 791048880050, 791048880082, 791048880114, 791048880146, 791048880178, 791048880210, 791048880242, 791057268658, 791057268690, 791057268722, 791057268754, 791057268786, 791057268818, 791057268850, 791065657266, 791065657298, 791065657330, 791065657362, 791065657394, 791065657426, 791065657458])).replace(' ','')



def test_kring_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@quadkey.KRING(NULL, 1)')
    assert "NULL argument passed to UDF" in str(excinfo.value)