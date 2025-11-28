from carto.lambda_wrapper import redshift_handler
from lib import longlat_as_int64_id


@redshift_handler
def process_s2_fromlonglat_row(row):
    """
    Convert longitude, latitude, and resolution to S2 cell ID.

    Args:
        row: [longitude, latitude, resolution]

    Returns:
        S2 cell ID as INT8
    """
    if row is None or len(row) < 3:
        raise Exception("Invalid row structure")

    longitude_str, latitude_str, resolution = row[0], row[1], row[2]

    if longitude_str is None or latitude_str is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    # Convert VARCHAR to float - preserves precision
    longitude = float(longitude_str)
    latitude = float(latitude_str)

    return longlat_as_int64_id(longitude, latitude, int(resolution))


lambda_handler = process_s2_fromlonglat_row
