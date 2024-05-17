#
#   An utility script to install javascript / sql script from stage.
#

from snowflake.snowpark.session import Session

## ------------------------------------ START -------------------
##  The core block for implementation logic

import logging ,os ,sys

logging.basicConfig(stream=sys.stdout, level=logging.INFO)
logger = logging.getLogger(__name__)

IMPORT_DIR = sys._xoptions["snowflake_import_directory"]

# -------------------------------------
def _list_files(p_local_dir):
    local_files = []
    for path, currentDirectory, files in os.walk(p_local_dir):
        for file in files:
            # build the relative paths to the file
            local_file = os.path.join(path, file)
            local_files.append(local_file)

    return local_files

def _read_script_fl(p_scriptfl :str):
    file_content = ''
    with open(p_scriptfl, 'r', encoding='utf-8') as f:
        file_content = f.read()

    return file_content

def main(p_session :Session) -> str:
    import_files = _list_files(IMPORT_DIR)
    for fl in  import_files:
        if '.sql' not in fl:
            continue
        query = _read_script_fl(fl)
        return f'''BEGIN
{query}
END;''';

    return ''
