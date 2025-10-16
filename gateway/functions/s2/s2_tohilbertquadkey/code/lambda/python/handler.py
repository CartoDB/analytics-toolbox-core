from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler
from lib import id_to_hilbert_quadkey


@redshift_handler
def process_s2_tohilbertquadkey_row(row):
    """
    Convert S2 cell ID to Hilbert quadkey string.

    Args:
        row: [id]

    Returns:
        Hilbert quadkey string
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    cell_id = row[0]

    if cell_id is None:
        raise Exception("NULL argument passed to UDF")

    return id_to_hilbert_quadkey(int(cell_id))


lambda_handler = process_s2_tohilbertquadkey_row
