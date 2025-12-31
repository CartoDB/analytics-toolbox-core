from carto.lambda_wrapper import redshift_handler
from lib import uint64_to_int64


@redshift_handler
def process_s2_fromuint64repr_row(row):
    """
    Convert UINT64 string representation to S2 cell ID.

    Args:
        row: [uid]

    Returns:
        S2 cell ID as INT8
    """
    if row is None or len(row) < 1:
        raise Exception("Invalid row structure")

    uid = row[0]

    if uid is None:
        raise Exception("NULL argument passed to UDF")

    return uint64_to_int64(int(str(uid)))


lambda_handler = process_s2_fromuint64repr_row
