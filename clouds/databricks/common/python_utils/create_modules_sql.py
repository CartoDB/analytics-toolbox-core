import os
import sys


if len(sys.argv) < 3 or len(sys.argv) > 4:
    raise Exception('Parameters: sql-directory, output-file[, schema]')


sql_path = sys.argv[1]
output_file = sys.argv[2]
schema = sys.argv[3] if len(sys.argv) > 3 else None


def sql_file(file_name):
    with open(file_name, 'r') as file:
        sql = file.read()
    if not schema:
        sql = sql.replace('@@DB_SCHEMA@@.', '')
    else:
        sql = sql.replace('@@DB_SCHEMA@@', schema)
    return sql


if __name__ == '__main__':
    modules = os.listdir(sql_path)
    # TODO: apply filters (modules, functions, diff)
    sql = ''
    if schema:
        sql += f'CREATE SCHEMA IF NOT EXISTS {schema};\n'
    for module_path, c_dir, module_files in os.walk(sql_path):
        for file_name in module_files:
            if file_name.endswith(".sql"):
                file_path = os.path.join(module_path, file_name)
                sql += sql_file(file_path) + '\n'
    output_path = os.path.dirname(output_file)
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    with open(output_file, 'w') as file:
        file.write(sql)
