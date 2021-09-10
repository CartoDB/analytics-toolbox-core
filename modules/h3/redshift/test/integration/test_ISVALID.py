from test_utils import run_query


def test_isvalid():

#    result = run_query('''
#        SELECT @@RS_PREFIX@@placekey.ISVALID(NULL)
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('@abc')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('abc-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('abcxyz234')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('abc@abc-234-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('ebc-345@abc-234-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('bcd-345@')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('22-zzz@abc-234-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('abc-234-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('@abc-234-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('bcd-2u4-xez')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('zzz@abc-234-xyz')
#        UNION ALL
#        SELECT @@RS_PREFIX@@placekey.ISVALID('222-zzz@abc-234-xyz')
#    ''')
#    
#    assert result[0][0] == False
#    assert result[1][0] == False
#    assert result[2][0] == False
#    assert result[3][0] == False
#    assert result[4][0] == False
#    assert result[5][0] == False
#    assert result[6][0] == False
#    assert result[7][0] == False
#    assert result[8][0] == True
#    assert result[9][0] == True
#    assert result[10][0] == True
#    assert result[11][0] == True
#    assert result[12][0] == True