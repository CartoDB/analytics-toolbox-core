from carto.lambda_wrapper import redshift_handler
from lib import to_parent


@redshift_handler
def process_s2_toparent_row(row):
    """
    Get the parent S2 cell at a specific resolution.

    Args:
        row: [id, resolution] or [id]

    Returns:
        Parent S2 cell ID as INT8
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    cell_id = row[0]

    if cell_id is None:
        raise Exception("NULL argument passed to UDF")

    # Check if resolution parameter is provided
    if len(row) >= 2:
        resolution = row[1]
        if resolution is None:
            raise Exception("NULL argument passed to UDF")
        return to_parent(int(cell_id), int(resolution))
    else:
        return to_parent(int(cell_id))


lambda_handler = process_s2_toparent_row
