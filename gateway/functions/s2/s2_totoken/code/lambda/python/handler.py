from carto.lambda_wrapper import redshift_handler
from lib import int64_id_to_token


@redshift_handler
def process_s2_totoken_row(row):
    """
    Convert S2 cell ID to token string.

    Args:
        row: [id]

    Returns:
        Token string
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    cell_id = row[0]

    if cell_id is None:
        raise Exception("NULL argument passed to UDF")

    return int64_id_to_token(int(cell_id))


lambda_handler = process_s2_totoken_row
