from carto.lambda_wrapper import redshift_handler
from lib import placekey_ash3


@redshift_handler
def process_placekey_ash3_row(row):
    """Process a single placekey_ash3 request row."""
    if row is None or len(row) < 1:
        return None

    placekey = row[0]

    if placekey is None:
        return None

    result = placekey_ash3(str(placekey))
    return result


lambda_handler = process_placekey_ash3_row
