from carto.lambda_wrapper import redshift_handler
from lib import polyfill_bbox


@redshift_handler
def process_s2_polyfill_bbox_row(row):
    """
    Polyfill a bounding box with S2 cells.

    Args:
        row: [min_lng, max_lng, min_lat, max_lat, min_res, max_res]
              or [min_lng, max_lng, min_lat, max_lat]

    Returns:
        JSON array string of S2 cell IDs
    """
    if row is None or len(row) < 4:
        raise Exception("Invalid row structure")

    min_lng, max_lng, min_lat, max_lat = row[0], row[1], row[2], row[3]

    if min_lng is None or max_lng is None or min_lat is None or max_lat is None:
        raise Exception("NULL argument passed to UDF")

    # Check if resolution parameters are provided
    if len(row) >= 6:
        min_res = row[4]
        max_res = row[5]
        if min_res is None or max_res is None:
            raise Exception("NULL argument passed to UDF")
        return polyfill_bbox(
            float(min_lng),
            float(max_lng),
            float(min_lat),
            float(max_lat),
            int(min_res),
            int(max_res),
        )
    else:
        return polyfill_bbox(
            float(min_lng), float(max_lng), float(min_lat), float(max_lat)
        )


lambda_handler = process_s2_polyfill_bbox_row
