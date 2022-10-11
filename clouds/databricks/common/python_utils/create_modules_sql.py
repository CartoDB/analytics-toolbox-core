import os
import sys

python_util_path = os.path.dirname(os.path.realpath(__file__))
output_file = os.path.join(python_util_path, '..', '..', 'modules', 'build', 'sql', 'modules.sql')
schema = None

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
        sql += f'USE {schema};\n'
    for module_path, c_dir, module_files in os.walk(sql_path):
        for file_name in module_files:
            if file_name.endswith(".sql"):
                file_path = os.path.join(module_path, file_name)
                with open(file_path, 'r') as file:
                    sql += '\n' + file.read()
    output_path = os.path.dirname(output_file)
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    with open(output_file, 'w') as file:
        file.write(sql)
