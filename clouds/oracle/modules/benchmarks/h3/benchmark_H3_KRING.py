"""Benchmark for H3_KRING.

Run with:
    cd clouds/oracle && make benchmark modules=h3 functions=H3_KRING
Or directly:
    python clouds/oracle/modules/benchmarks/h3/benchmark_H3_KRING.py

Edit the constants below to point at your dev table.
"""
from test_utils import bench

# === Tweak for your environment ===
SOURCE_TABLE = '@@ORA_SCHEMA@@.SAMPLE_TABLE'
H3_COLUMN = 'h3'
K = 2

if __name__ == '__main__':
    bench(
        name=f'H3_KRING(h3, {K})',
        sql=(
            f'SELECT COUNT(*) FROM {SOURCE_TABLE} t, '
            f'TABLE(@@ORA_SCHEMA@@.H3_KRING(t.{H3_COLUMN}, {K}))'
        ),
    )
