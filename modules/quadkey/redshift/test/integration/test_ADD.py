import os
import redshift_connector


# Connects to Redshift cluster using AWS credentials
conn = redshift_connector.connect(
    host=os.environ["RS_HOST"],
    database=os.environ["RS_DATABASE"],
    user=os.environ["RS_USER"],
    password=os.environ["RS_PASSWORD"],
)
schema_prefix = os.environ["RS_SCHEMA_PREFIX"]
cursor = conn.cursor()


def test_add():
    cursor.execute(f"SELECT {schema_prefix}quadkey.ADD(123, 245)")
    result = cursor.fetchall()

    assert result[0][0] == 368
