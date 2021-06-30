import redshift_connector
import os

# Connects to Redshift cluster using AWS credentials
conn = redshift_connector.connect(
    host='redshift-cluster-1.c2gsqdockj5a.us-east-2.redshift.amazonaws.com',
    database='dev',
    user=os.environ["RS_USER"],
    password='awsC4rt0'
)

cursor= conn.cursor()
cursor.execute("create Temp table book(bookname varchar,author varchar)")
cursor.executemany("insert into book (bookname, author) values (%s, %s)",
                    [
                        ('One Hundred Years of Solitude', 'Gabriel Garcia Marquez'),
                        ('A Brief History of Time', 'Stephen Hawking')
                    ]
                  )
cursor.execute("select * from book")

result = cursor.fetchall()
print(result)
