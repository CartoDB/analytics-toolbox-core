# Copyright (c) 2026, CARTO

from benchmark_utils import bench, config_for

for case in config_for('H3_KRING'):
    bench(
        function='H3_KRING',
        params=case,
        sql=(
            'SELECT COUNT(*) FROM {source_table} t, '
            'TABLE(@@ORA_SCHEMA@@.H3_KRING(t.{h3_column}, {size}))'
        ),
    )
