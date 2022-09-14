import sqlfluff
import sys

scripts = sys.argv[1].split(' ')
for script in scripts:
    content = ''
    with open(script, 'r') as file:
        content = file.read().replace('@', '_sqlfluff_')
    # , exclude_rules= ['L003', 'L016']
    fixed_content = (
        sqlfluff.fix(content, dialect='bigquery', exclude_rules= ['L016'])
        .replace('_sqlfluff_', '@')
        .replace('_SQLFLUFF_', '@')
    )
    with open(script, 'w') as file:
        file.write(fixed_content)
