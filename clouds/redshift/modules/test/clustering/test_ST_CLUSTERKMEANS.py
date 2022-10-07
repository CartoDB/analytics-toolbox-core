import os

from test_utils import run_query

here = os.path.dirname(__file__)


def test_st_clusterkmeans():
    with open(f'{here}/fixtures/st_clusterkmeans_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    results = run_query(
        f"""
        WITH __input AS (
            SELECT '{lines[0].rstrip()}' wkt, 2 n UNION ALL
            SELECT '{lines[1].rstrip()}', 3 UNION ALL
            SELECT '{lines[1].rstrip()}', 5
        )
        SELECT @@RS_SCHEMA@@.ST_CLUSTERKMEANS(ST_GEOMFROMTEXT(wkt), n)
        FROM __input
    """
    )

    with open(f'{here}/fixtures/st_clusterkmeans_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_st_clusterkmeans_default_args_success():
    with open(f'{here}/fixtures/st_clusterkmeans_in.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    result = run_query(
        f"""SELECT @@RS_SCHEMA@@.ST_CLUSTERKMEANS(
                    ST_GEOMFROMTEXT('{lines[2].rstrip()}'), 3),
                   @@RS_SCHEMA@@.ST_CLUSTERKMEANS(
                    ST_GEOMFROMTEXT('{lines[2].rstrip()}'))"""
    )

    assert result[0][1] == result[0][0]
