# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql="""SELECT COUNT(*) FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(
    SDO_UTIL.FROM_WKTGEOMETRY('${geog}'),
    ${resolution}
))""",
)
