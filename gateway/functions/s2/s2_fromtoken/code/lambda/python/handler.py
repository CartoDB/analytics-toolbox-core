from carto.lambda_wrapper import redshift_handler
from lib import token_to_int64_id


@redshift_handler
def process_s2_fromtoken_row(row):
    """
    Convert token string to S2 cell ID.

    Args:
        row: [token]

    Returns:
        S2 cell ID as INT8
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    token = row[0]

    if token is None:
        raise Exception("NULL argument passed to UDF")

    return token_to_int64_id(str(token).encode())


lambda_handler = process_s2_fromtoken_row
