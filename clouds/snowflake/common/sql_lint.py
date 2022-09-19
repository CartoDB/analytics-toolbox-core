import logging
import sys
import sqlfluff

# Lint the sql files passed as input

current_script = ''


def _logging_handle(self, record):
    raise Exception('ERROR: ' + record.msg + '\nPlease check ' + current_script)


stream_handler = logging.StreamHandler
stream_handler.handle = _logging_handle

scripts = sys.argv[1].split(' ')
ignored_files = sys.argv[3]
if ignored_files:
    with open(ignored_files, 'r') as ignored_file:
        ignored_scripts = ignored_file.read().split('\n')
    for ignored_script in ignored_scripts:
        scripts = list(filter(lambda x: not x.endswith(ignored_script), scripts))

for script in scripts:
    current_script = script
    content = ''
    with open(script, 'r') as file:
        content = (
            file.read()
            .replace('@@SF_SCHEMA@@', '_sqlfluffschema_')
            .replace('@', '_sqlfluff_')
        )
    fixed_content = (
        sqlfluff.fix(content, dialect='snowflake', config_path=sys.argv[2])
        .replace('_sqlfluffschema_', '@@SF_SCHEMA@@')
        .replace('_SQLFLUFFSCHEMA_', '@@SF_SCHEMA@@')
        .replace('_sqlfluff_', '@')
        .replace('_SQLFLUFF_', '@')
    )
    with open(script, 'w') as file:
        file.write(fixed_content)
