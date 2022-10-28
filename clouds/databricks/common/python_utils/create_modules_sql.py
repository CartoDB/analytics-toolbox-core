import os
import sys


if len(sys.argv) < 3 or len(sys.argv) > 4:
    raise Exception('Parameters: sql-directory, output-file[, schema]')


# Use a space rather than : to separate paths for the convenience of using Make's += operator
sql_paths = sys.argv[1].split(' ')
output_file = sys.argv[2]
schema = sys.argv[3] if len(sys.argv) > 3 else None


def sql_file(file_name):
    with open(file_name, 'r') as file:
        sql = file.read()
    sql = sql.replace('@@DB_VERSION_FUNCTION@@', os.environ['DB_VERSION_FUNCTION'])
    sql = sql.replace('@@DB_VERSION_CLASS@@', os.environ['DB_VERSION_CLASS'])

    if not schema:
        sql = sql.replace('@@DB_SCHEMA@@.', '')
    else:
        sql = sql.replace('@@DB_SCHEMA@@', schema)
    return sql


if __name__ == '__main__':
    modules = [mod for mods in [os.walk(sql_path) for sql_path in sql_paths] for mod in mods]
    # TODO: apply filters (modules, functions, diff)
    sql = ''
    for module_path, c_dir, module_files in modules:
        for file_name in module_files:
            if file_name.endswith(".sql"):
                file_path = os.path.join(module_path, file_name)
                sql += sql_file(file_path) + '\n'
    output_path = os.path.dirname(output_file)
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    with open(output_file, 'w') as file:
        file.write(sql)
