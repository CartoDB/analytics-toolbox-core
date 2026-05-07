# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_POLYFILL_MODE',
    sql="""SELECT COUNT(*) FROM TABLE(@@ORA_SCHEMA@@.H3_POLYFILL_MODE(
    SDO_UTIL.FROM_WKTGEOMETRY('${geog}'),
    ${resolution},
    '${mode}'
))""",
)
