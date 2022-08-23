from test_utils import run_query


def test_isvalid():

    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID(NULL)
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('@abc')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abc-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abcxyz234')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abc@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('ebc-345@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('bcd-345@')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('22-zzz@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('bcd-2u4-xez')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('zzz@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('222-zzz@abc-234-xyz')
    """
    )

    assert result[0][0] is False
    assert result[1][0] is False
    assert result[2][0] is False
    assert result[3][0] is False
    assert result[4][0] is False
    assert result[5][0] is False
    assert result[6][0] is False
    assert result[7][0] is False
    assert result[8][0] is True
    assert result[9][0] is True
    assert result[10][0] is True
    assert result[11][0] is True
    assert result[12][0] is True
