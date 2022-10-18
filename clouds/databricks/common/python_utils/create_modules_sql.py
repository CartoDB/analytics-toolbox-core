import os
import sys

python_util_path = os.path.dirname(os.path.realpath(__file__))
output_file = os.path.join(python_util_path, '..', '..', 'modules', 'build', 'sql', 'modules.sql')
schema = None

def sql_file(file_name):
    with open(file_name, 'r') as file:
        sql = file.read()
    if not schema:
        sql = sql.replace('@@DB_SCHEMA@@.', '')
    else:
      return sql.replace('@@DB_SCHEMA@@', schema)

if len(sys.argv) > 1:
    output_file = sys.argv[1]
    if len(sys.argv) > 2:
        schema = sys.argv[2]

if __name__ == '__main__':
    sql_path = os.path.join(python_util_path, '..', '..', 'modules', 'sql')
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
