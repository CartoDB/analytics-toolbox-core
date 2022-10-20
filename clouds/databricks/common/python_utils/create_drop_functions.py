import os
import sys


if len(sys.argv) < 3 or len(sys.argv) > 4:
    raise Exception('Parameters: sql-directory, output-file[, schema]')


# Use a space rather than : to separate paths for the convenience of using Make's += operator
sql_paths = sys.argv[1].split(' ')
output_file = sys.argv[2]
schema = sys.argv[3] if len(sys.argv) > 3 else None


def get_uninstall_for_module(module_path, queries_list):
    database = schema
    database = 'default' if database is None else database
    _, _, functions = next(os.walk(module_path))
    # FIXME: should we read the SQL file, extract the @@DB_SCHEMA@@.function_name
    # from the definition and substitute the schema?
    for function in functions:
        if not function.endswith('.sql'):
            continue
        function_name = function[:-4]
        queries_list.append(f'DROP FUNCTION IF EXISTS {database}.{function_name};')


def write_queries(final_query):
    with open(output_file, 'w') as file:
        file.write(final_query)


if __name__ == '__main__':
    queries_list = []
    for sql_path in sql_paths:
        modules = os.listdir(sql_path)
        # We filter paths that aren't a directory
        modules = list(filter(lambda x: os.path.isdir(os.path.join(sql_path, x)), modules))
        for module in modules:
            module_path = os.path.join(sql_path, module)
            get_uninstall_for_module(module_path, queries_list)
    final_query = '\n'.join(queries_list)
    write_queries(final_query)

