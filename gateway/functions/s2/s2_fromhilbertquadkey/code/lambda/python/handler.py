from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler
from lib import hilbert_quadkey_to_id


@redshift_handler
def process_s2_fromhilbertquadkey_row(row):
    """
    Convert Hilbert quadkey string to S2 cell ID.

    Args:
        row: [hquadkey]

    Returns:
        S2 cell ID as INT8
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    hquadkey = row[0]

    if hquadkey is None:
        raise Exception("NULL argument passed to UDF")

    return hilbert_quadkey_to_id(str(hquadkey))


lambda_handler = process_s2_fromhilbertquadkey_row
