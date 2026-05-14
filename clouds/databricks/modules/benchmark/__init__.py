import os
import sys

# Include this to allow importing benchmark_utils / test_utils from source code
sys.path.insert(
    1,
    os.path.join(
        os.path.dirname(os.path.realpath(__file__)),
        '..',
        '..',
        'common',
    ),
)
