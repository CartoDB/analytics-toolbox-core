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

    longitude, latitude, resolution = row[0], row[1], row[2]

    if longitude is None or latitude is None or resolution is None:
        raise Exception("NULL argument passed to UDF")

    return longlat_as_int64_id(float(longitude), float(latitude), int(resolution))


lambda_handler = process_s2_fromlonglat_row
