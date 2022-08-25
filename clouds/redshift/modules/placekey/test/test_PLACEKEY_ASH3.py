from test_utils import run_query


def test_placekey_ash3():

    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@c6z-c2g-dgk')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@63m-vc4-z75')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@7qg-xf9-j5f')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@bhm-9m8-gtv')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@h5z-gcq-kvf')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@7v4-m2p-3t9')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@hvb-5d7-92k')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@ab2-k43-xqz')
    """
    )

    assert result[0][0] == '8a62e9d08a1ffff'
    assert result[1][0] == '8a2a9c580577fff'
    assert result[2][0] == '8a3c9ea2bd4ffff'
    assert result[3][0] == '8a5b4c1047b7fff'
    assert result[4][0] == '8a8e8116a6d7fff'
    assert result[5][0] == '8a3e0ba6659ffff'
    assert result[6][0] == '8a961652a407fff'
    assert result[7][0] == '8a01262c914ffff'

    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3(NULL)
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@abc')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('abc-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('abcxyz234')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('abc-345@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('ebc-345@abc-234-xyz')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('bcd-345@')
        UNION ALL
        SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('22-zzz@abc-234-xyz')
    """
    )

    assert result[0][0] is None
    assert result[1][0] is None
    assert result[2][0] is None
    assert result[3][0] is None
    assert result[4][0] is None
    assert result[5][0] is None
    assert result[6][0] is None
    assert result[7][0] is None
