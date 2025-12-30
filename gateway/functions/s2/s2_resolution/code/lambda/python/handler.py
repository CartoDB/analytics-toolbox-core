from carto.lambda_wrapper import redshift_handler
from lib import get_resolution


@redshift_handler
def process_s2_resolution_row(row):
    """
    Get the resolution (level) of an S2 cell.

    Args:
        row: [id]

    Returns:
        Resolution as INT4
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    cell_id = row[0]

    if cell_id is None:
        raise Exception("NULL argument passed to UDF")

    return get_resolution(int(cell_id))


lambda_handler = process_s2_resolution_row
