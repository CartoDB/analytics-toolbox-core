import os
import redshift_connector

from lib import quadkeyLib


# Connects to Redshift cluster using AWS credentials
conn = redshift_connector.connect(
    host=os.environ["RS_HOST"],
    database=os.environ["RS_DATABASE"],
    user=os.environ["RS_USER"],
    password=os.environ["RS_PASSWORD"],
)
schema_prefix = os.environ["RS_SCHEMA_PREFIX"]
cursor = conn.cursor()


def test_version():
    cursor.execute(f"SELECT {schema_prefix}quadkey.VERSION()")
    result = cursor.fetchall()

    assert result[0][0] == quadkeyLib.__version__
