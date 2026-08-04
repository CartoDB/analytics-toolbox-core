from test_utils import run_queries

# One metre expressed in degrees of latitude, exact on the sphere that
# ST_DistanceSphere measures on (R = 6371008.8 m). Latitude is used for the
# fixtures that need precise spacing because, unlike longitude, a degree of
# latitude does not shrink with cos(lat).
LAT_M = 1.0 / 111195.0797


def _pt(lat_metres, lon=-3.70, lat0=40.41):
    """Return a point offset north of (lon, lat0) by an exact metre count."""
    return f'ST_SetSRID(ST_Point({lon},{lat0 + lat_metres * LAT_M}),4326)'


def _drop(table):
    return [
        f"""drop table if exists @@RS_SCHEMA@@.{table}""",
        f"""drop table if exists @@RS_SCHEMA@@.{table}_out""",
    ]


def _setup(table, rows, with_part=False):
    cols = (
        'id INT, part VARCHAR(16), geom GEOMETRY'
        if with_part
        else 'id INT, geom GEOMETRY'
    )
    return _drop(table) + [
        f"""create table @@RS_SCHEMA@@.{table}({cols})""",
        f"""insert into @@RS_SCHEMA@@.{table} values {rows}""",
    ]


def test_create_clusterdbscan():
    """Two dense groups cluster, two distant points are noise.

    The procedure is called twice to confirm it can be re-run in the same
    session: it drops and recreates internal temp tables on every call, so all
    of its statements use dynamic SQL to avoid a stale cached plan.
    """
    rows = ','.join(
        [f'({i + 1},{_pt(i * 10)})' for i in range(3)]
        + [f'({i + 11},{_pt(500 + i * 10)})' for i in range(3)]
        + [f'(90,{_pt(5000)})', f'(91,{_pt(9000)})']
    )
    call = """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
        '@@RS_SCHEMA@@.dbscan_basic',
        '@@RS_SCHEMA@@.dbscan_basic_out',
        'geom', 25, 3)"""
    results = run_queries(
        _setup('dbscan_basic', rows)
        + [call, call]
        + [
            """select min(cluster_id), max(cluster_id),
                      count(distinct cluster_id),
                      sum(case when cluster_id is null then 1 else 0 end),
                      sum(case when pt_type = 'core' then 1 else 0 end)
               from @@RS_SCHEMA@@.dbscan_basic_out"""
        ]
    )
    # cluster_id is dense and zero-based, as in scikit-learn and BigQuery
    assert results[0] == [0, 1, 2, 2, 6]
    run_queries(_drop('dbscan_basic'))


def test_create_clusterdbscan_core_border_and_noise():
    """Border points join a cluster but never merge two clusters.

    Points sit at exact metre offsets 0, 12, 24, 48, 72, 84, 96 along a
    meridian, with epsilon = 25 and min_points = 4. Only the points at 24 m and
    72 m reach 4 neighbours counting themselves, so they are the only cores,
    and they are 48 m apart -- beyond epsilon -- so they cannot be density
    connected. The point at 48 m is within epsilon of both cores but is not
    itself a core, so it joins one cluster without merging them. This is the
    case that separates DBSCAN from single-linkage clustering.
    """
    rows = ','.join(
        f'({i + 1},{_pt(p)})' for i, p in enumerate([0, 12, 24, 48, 72, 84, 96])
    )
    results = run_queries(
        _setup('dbscan_types', rows)
        + [
            """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
                '@@RS_SCHEMA@@.dbscan_types',
                '@@RS_SCHEMA@@.dbscan_types_out',
                'geom', 25, 4)""",
            """select count(distinct cluster_id),
                      sum(case when pt_type = 'core' then 1 else 0 end),
                      sum(case when pt_type = 'border' then 1 else 0 end),
                      sum(case when pt_type = 'noise' then 1 else 0 end)
               from @@RS_SCHEMA@@.dbscan_types_out""",
        ]
    )
    assert results[0] == [2, 2, 5, 0]
    run_queries(_drop('dbscan_types'))


def test_create_clusterdbscan_null_geometry_is_skipped():
    """A NULL geometry is reported as skipped, not as noise."""
    rows = ','.join([f'({i + 1},{_pt(i * 10)})' for i in range(3)] + ['(8,NULL)'])
    results = run_queries(
        _setup('dbscan_null', rows)
        + [
            """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
                '@@RS_SCHEMA@@.dbscan_null',
                '@@RS_SCHEMA@@.dbscan_null_out',
                'geom', 25, 3)""",
            """select pt_type, cluster_id
               from @@RS_SCHEMA@@.dbscan_null_out where id = 8""",
        ]
    )
    assert results[0] == ['skipped', None]
    run_queries(_drop('dbscan_null'))


def test_create_clusterdbscan_partition_column():
    """Cluster each partition independently.

    Identical geometry in two partitions yields one cluster per partition, and
    cluster_id restarts at zero in every partition.
    """
    rows = ','.join(
        [f"({i + 1},'a',{_pt(i * 10)})" for i in range(3)]
        + [f"({i + 4},'b',{_pt(i * 10)})" for i in range(3)]
    )
    results = run_queries(
        _setup('dbscan_part', rows, with_part=True)
        + [
            """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
                '@@RS_SCHEMA@@.dbscan_part',
                '@@RS_SCHEMA@@.dbscan_part_out',
                'geom', 25, 3, 'part')""",
            """select count(distinct part || ':' || cluster_id),
                      count(distinct cluster_id)
               from @@RS_SCHEMA@@.dbscan_part_out
               where cluster_id is not null""",
        ]
    )
    assert results[0] == [2, 1]
    run_queries(_drop('dbscan_part'))


def test_create_clusterdbscan_handles_antimeridian_and_high_latitude():
    """Exercise the two hard cases for the neighbour pre-filter.

    It must wrap across +/-180, and it must size its longitude cells using
    cos(latitude) so that high-latitude neighbours are not missed.
    """
    anti = ','.join(
        [
            '(1,ST_SetSRID(ST_Point(179.99995,0),4326))',
            '(2,ST_SetSRID(ST_Point(-179.99995,0),4326))',
            '(3,ST_SetSRID(ST_Point(179.99985,0),4326))',
            '(9,ST_SetSRID(ST_Point(150,0),4326))',
        ]
    )
    results = run_queries(
        _setup('dbscan_anti', anti)
        + [
            """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
                '@@RS_SCHEMA@@.dbscan_anti',
                '@@RS_SCHEMA@@.dbscan_anti_out',
                'geom', 25, 3)""",
            """select count(distinct cluster_id),
                      sum(case when pt_type = 'noise' then 1 else 0 end)
               from @@RS_SCHEMA@@.dbscan_anti_out""",
        ]
    )
    assert results[0] == [1, 1]
    run_queries(_drop('dbscan_anti'))

    polar = ','.join(
        [f'({i + 1},{_pt(i * 30, lon=10.0, lat0=85.0)})' for i in range(3)]
        + [f'(9,{_pt(0, lon=20.0, lat0=85.0)})']
    )
    results = run_queries(
        _setup('dbscan_polar', polar)
        + [
            """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
                '@@RS_SCHEMA@@.dbscan_polar',
                '@@RS_SCHEMA@@.dbscan_polar_out',
                'geom', 120, 3)""",
            """select count(distinct cluster_id),
                      sum(case when pt_type = 'noise' then 1 else 0 end)
               from @@RS_SCHEMA@@.dbscan_polar_out""",
        ]
    )
    assert results[0] == [1, 1]
    run_queries(_drop('dbscan_polar'))


def test_create_clusterdbscan_converges_on_a_long_chain():
    """A 300 point chain is one cluster of diameter ~298.

    Label propagation reaches the fixpoint in O(log n) passes because each
    pass also compresses the label pointers. Plain propagation would need one
    pass per link and would exhaust the iteration guard, so this is the
    regression test for that behaviour.
    """
    rows = ','.join(f'({i + 1},{_pt(i * 20)})' for i in range(300))
    results = run_queries(
        _setup('dbscan_chain', rows)
        + [
            """call @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
                '@@RS_SCHEMA@@.dbscan_chain',
                '@@RS_SCHEMA@@.dbscan_chain_out',
                'geom', 25, 2)""",
            """select count(distinct cluster_id), count(*)
               from @@RS_SCHEMA@@.dbscan_chain_out
               where cluster_id is not null""",
        ]
    )
    assert results[0] == [1, 300]
    run_queries(_drop('dbscan_chain'))
