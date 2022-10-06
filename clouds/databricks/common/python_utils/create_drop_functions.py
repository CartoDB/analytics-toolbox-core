import os


python_util_path = os.path.dirname(os.path.realpath(__file__))


def get_uninstall_for_module(module_path, queries_list):
    database = os.getenv('DB_SCHEMA')
    database = 'default' if database is None else database
    _, _, functions = next(os.walk(module_path))
    for function in functions:
        if not function.endswith('.sql'):
            continue
        function_name = function[:-4]
        queries_list.append(f'DROP FUNCTION IF EXISTS {database}.{function_name};')


def write_queries(final_query):
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
    else:
       file_path = os.path.join(python_util_path, '..', 'dropUDF.sql')
    with open(file_path, 'w') as file:
        file.write(final_query)


if __name__ == '__main__':
    sql_path = os.path.join(python_util_path, '..', '..', 'modules', 'sql')
    modules = os.listdir(sql_path)
    # We filter paths that aren't a directory
    modules = list(filter(lambda x: os.path.isdir(os.path.join(sql_path, x)), modules))
    queries_list = []
    for module in modules:
        module_path = os.path.join(sql_path, module)
        get_uninstall_for_module(module_path, queries_list)
    final_query = '\n'.join(queries_list)
    write_queries(final_query)
