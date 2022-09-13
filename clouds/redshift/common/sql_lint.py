import sqlfluff
import sys

#  -------- LINTING ----------

my_bad_query = "SeLEct  *, 1, blah as  fOO  from mySchema.myTable"
script = sys.argv[1]
with open(script, 'r') as file:
    my_bad_query = file.read()

fix_result_1 = sqlfluff.fix(my_bad_query, dialect="redshift")

print(fix_result_1)