from python_utils.run_query import run_query


def test_st_extentfromgeom_success():
    query = (
        'SELECT @@DB_SCHEMA@@.ST_EXTENTFROMGEOM(@@DB_SCHEMA@@.ST_MAKEBBOX(0, 0, 1, 1))'
    )
    result = run_query(query)
    assert result[0][0] == {'xmin': 0, 'ymin': 0, 'xmax': 1, 'ymax': 1}
