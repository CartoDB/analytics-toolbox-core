from lib import h3


def test_h3():
    g = h3.h3_cell_to_latlng(0x85283473FFFFFFF)
    assert g.lng == -121.9763759725512
    assert g.lat == 37.34579337536848
