from re import sub

def norm_sql(sql):
    sql = sub('\s+', ' ', sql)
    sql = sub('\s?,\s?', ',', sql)
    sql = sub('\( ', '(', sql)
    sql = sub(' \)', ')', sql)
    return sql.strip()
