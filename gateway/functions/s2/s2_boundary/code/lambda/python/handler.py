from carto.lambda_wrapper import redshift_handler
from lib import get_cell_boundary


@redshift_handler
def process_s2_boundary_row(row):
    """
    Get the boundary of an S2 cell as WKT polygon.

    Args:
        row: [id]

    Returns:
        WKT polygon string
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    cell_id = row[0]

    if cell_id is None:
        raise Exception("NULL argument passed to UDF")

    return get_cell_boundary(int(cell_id))


lambda_handler = process_s2_boundary_row
