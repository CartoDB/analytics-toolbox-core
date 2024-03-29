import os
import re
import shutil
from jinja2 import Environment, FileSystemLoader, select_autoescape


test_util_path = os.path.dirname(os.path.realpath(__file__))


def create_it_from_docs():
    module_path = os.path.join(test_util_path, '..', '..', 'modules')
    modules = os.listdir(module_path)
    for module in modules:
        print(f'Working on module {module}')
        create_tests_for_module(module_path, module)


def create_tests_for_module(path, module):
    doc_path = os.path.join(path, module, 'doc')
    test_path = os.path.join(path, module, 'test')
    create_test_path(test_path)
    _, _, functions = next(os.walk(doc_path))
    for function in functions:
        print(f'Creating test for function {function}')
        create_test_for_function(test_path, doc_path, function)


def create_test_for_function(test_path, doc_path, function):
    query, result = get_query_and_result(os.path.join(doc_path, function))
    if not query:
        return
    function_name = function.replace('.md', '')
    env = Environment(
        loader=FileSystemLoader(test_util_path + '/resources'),
        autoescape=select_autoescape(),
    )
    # Preparing the variables to render the template
    variables = {
        'functionname_lower': function_name.lower(),
        'query': query,
        'result': result,
    }
    template = env.get_template('test_template.py')

    output_from_parsed_template = template.render(variables)
    # Will save the parsed template to the test file
    test_filename = 'test_' + function_name + '.py'
    try:
        with open(os.path.join(test_path, test_filename), 'x') as file:
            file.write(output_from_parsed_template)
    except FileExistsError:
        print(f'The test {test_filename} already exists, will not create it')


def create_test_path(test_path):
    if not os.path.exists(test_path):
        print(f'Creating test folder {test_path}')
        os.makedirs(test_path)
        src = os.path.join(test_util_path, 'resources/test_modules_init.py')
        dest = os.path.join(test_path, '__init__.py')
        shutil.copyfile(src, dest)


def get_query_and_result(path):
    with open(path, 'r') as f:
        lines = f.read()
    match = re.search('```sql(.*)```', lines, flags=re.DOTALL)
    if match:
        query = match.group(1).strip()
        # The text before -- will be the query and the text after it will be the expected result
        result_position = query.find('--')
        subquery = query[:result_position].strip()
        subquery = subquery.replace('carto.', '@@DB_SCHEMA@@.').replace('"', "'")
        if '\n' in subquery:
            # if there is a multiline query, we add "" at the beggining and end of the query
            # in order to make it a python multiline string when rendering the template
            subquery = '""' + subquery + '""'
        result = query[result_position + 2 :].strip()
        # TODO: add logic to check the type of result and adapt it automatically, boolean, string, int
        return subquery, result
    print('Unable to parse doc file, will not create test for it')
    return None, None


create_it_from_docs()
