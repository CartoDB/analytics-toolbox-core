from test_utils import run_queries


def test_create_clusterkmeans():
    results = run_queries(
        [
            """drop table if exists @@RS_SCHEMA@@.table_10_rows""",
            """drop table if exists @@RS_SCHEMA@@.table_10_rows_output""",
            """create table @@RS_SCHEMA@@.table_10_rows(geom GEOMETRY)""",
            """insert into @@RS_SCHEMA@@.table_10_rows values
                (ST_GeomFromText('POINT (-84.4969434583242 39.0434580258414)')),
                (ST_GeomFromText('POINT (-95.4005538123092 29.8872580176726)')),
                (ST_GeomFromText('POINT (-84.8879539036345 33.7072237906569)')),
                (ST_GeomFromText('POINT (-114.644576395789 32.5849582471974)')),
                (ST_GeomFromText('POINT (-85.3651561518078 39.9769805773149)')),
                (ST_GeomFromText('POINT (-71.6991797105415 42.4263206545098)')),
                (ST_GeomFromText('POINT (-81.3013451654937 35.460968522182)')),
                (ST_GeomFromText('POINT (-81.2811413776769 35.2455946775913)')),
                (ST_GeomFromText('POINT (-74.8508251755142 40.2411534635632)')),
                (ST_GeomFromText('POINT (-121.804749862726 38.6737474085954)'))""",
            """call @@RS_SCHEMA@@.CREATE_CLUSTERKMEANS(
                '@@RS_SCHEMA@@.table_10_rows',
                '@@RS_SCHEMA@@.table_10_rows_output',
                'geom', 2)""",
            """select cluster_id
            from @@RS_SCHEMA@@.table_10_rows_output""",
        ]
    )
    assert len(results) == 10
    for result in results:
        assert result[0] >= 0 and result[0] < 2

    results = run_queries(
        [
            """drop table if exists @@RS_SCHEMA@@.table_10_rows""",
            """drop table if exists @@RS_SCHEMA@@.table_10_rows_output""",
        ]
    )
