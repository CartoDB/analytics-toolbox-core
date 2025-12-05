"""
Pytest configuration for platforms directory
Prevents pytest from importing __init__.py files with relative imports
"""

collect_ignore = ["aws-lambda/__init__.py"]
