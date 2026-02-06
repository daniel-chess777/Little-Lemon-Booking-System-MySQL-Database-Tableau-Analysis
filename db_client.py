
"""
Simple MySQL client for Little Lemon (Python 3)
Requires: pip install mysql-connector-python
"""
import os
import mysql.connector as mysql

DB_HOST = os.getenv('LL_DB_HOST','127.0.0.1')
DB_USER = os.getenv('LL_DB_USER','root')
DB_PASS = os.getenv('LL_DB_PASS','root')
DB_NAME = os.getenv('LL_DB_NAME','little_lemon')

cn = mysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_NAME, allow_local_infile=True)
cn.autocommit = True
cur = cn.cursor()

# Example: call GetMaxQuantity
cur.callproc('GetMaxQuantity', [0])
for res in cur.stored_results():
    max_qty = list(res)[0][0]
    print('Max quantity=', max_qty)

# Example: ManageBooking upsert
args = ['54-366-6861', '2020-06-15', 2, 10, 'Confirmed', 0]
cur.callproc('ManageBooking', args)
print('ManageBooking executed')

cur.close(); cn.close()
