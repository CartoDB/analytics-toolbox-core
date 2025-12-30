from carto.lambda_wrapper import redshift_handler
from lib import placekey_fromh3


@redshift_handler
def process_placekey_fromh3_row(row):
    """Process a single placekey_fromh3 request row."""
    if row is None or len(row) < 1:
        return None

    h3_index = row[0]

    if h3_index is None:
        return None

    result = placekey_fromh3(str(h3_index))
    return result


lambda_handler = process_placekey_fromh3_row
