from carto.lambda_wrapper import redshift_handler
from lib import placekey_isvalid


@redshift_handler
def process_placekey_isvalid_row(row):
    """Process a single placekey_isvalid request row."""
    if row is None or len(row) < 1:
        return None

    placekey = row[0]

    if placekey is None:
        return False

    result = placekey_isvalid(str(placekey))
    return result


lambda_handler = process_placekey_isvalid_row
