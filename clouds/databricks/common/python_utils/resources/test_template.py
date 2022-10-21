import os
from python_utils.run_query import run_query

def test_{{functionname_lower}}_success():
    query = "{{query}}"
    result = run_query(query)
    assert result[0][0] == "{{result}}"
