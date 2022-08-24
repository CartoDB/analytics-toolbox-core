#!/bin/bash

echo "Create integration tests from docs"
echo "-------------------------------------"
virtualenv -p python3 itvenv -q
source itvenv/bin/activate
python -m pip install -U pip -q
pip install -r requirements_create_it.txt -q
python test_utils/create_tests_from_doc.py
deactivate