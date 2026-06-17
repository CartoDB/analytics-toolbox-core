from test_utils import run_queries


POLYGON = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)

# Expected quadbin coverage of the test polygon at resolution 17.
EXPECTED_CELLS = sorted(
    [
        5265786693153193983,
        5265786693163941887,
        5265786693164204031,
        5265786693164466175,
        5265786693164728319,
        5265786693165514751,
    ]
)


def test_quadbin_polyfill_table():
    results = run_queries(
        [
            'drop table if exists @@RS_SCHEMA@@.quadbin_polyfill_table_input',
            'drop table if exists @@RS_SCHEMA@@.quadbin_polyfill_table_output',
            'create table @@RS_SCHEMA@@.quadbin_polyfill_table_input(geom GEOMETRY)',
            f"""insert into @@RS_SCHEMA@@.quadbin_polyfill_table_input
                values (ST_GeomFromText('{POLYGON}'))""",
            """call @@RS_SCHEMA@@.QUADBIN_POLYFILL_TABLE(
                'SELECT geom FROM @@RS_SCHEMA@@.quadbin_polyfill_table_input',
                17, 'intersects', '@@RS_SCHEMA@@.quadbin_polyfill_table_output')""",
            """select quadbin from @@RS_SCHEMA@@.quadbin_polyfill_table_output
                order by quadbin""",
        ]
    )
    cells = sorted(int(result[0]) for result in results)
    assert cells == EXPECTED_CELLS

    run_queries(
        [
            'drop table if exists @@RS_SCHEMA@@.quadbin_polyfill_table_input',
            'drop table if exists @@RS_SCHEMA@@.quadbin_polyfill_table_output',
        ]
    )
