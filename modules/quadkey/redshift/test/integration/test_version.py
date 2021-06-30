import redshift_connector
import os
import pytest

# Connects to Redshift cluster using AWS credentials
conn = redshift_connector.connect(
    host=os.environ["RS_HOST"],
    database=os.environ["RS_DATABASE"],
    user=os.environ["RS_USER"],
    password=os.environ["RS_PASSWORD"]
)
schema_prefix = os.environ["RS_SCHEMA_PREFIX"]
cursor= conn.cursor()

def test_version():
    version = 1
    cursor.execute(f"SELECT {schema_prefix}quadkey.f_distance(0,0,1,0)")
    result = cursor.fetchall()
    
    assert version == result[0][0]