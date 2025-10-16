from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler
from lib import uint64_repr_from_id


@redshift_handler
def process_s2_touint64repr_row(row):
    """
    Convert S2 cell ID to UINT64 string representation.

    Args:
        row: [id]

    Returns:
        UINT64 string representation
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    cell_id = row[0]

    if cell_id is None:
        raise Exception("NULL argument passed to UDF")

    return str(uint64_repr_from_id(int(cell_id)))


lambda_handler = process_s2_touint64repr_row
