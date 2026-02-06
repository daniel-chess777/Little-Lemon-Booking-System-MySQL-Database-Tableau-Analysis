
"""
Change watcher: polls change_log and reacts to inserts/updates/deletes on bookings.
Usage: python change_watcher.py
"""
import os, time, json
import mysql.connector as mysql

DB_HOST = os.getenv('LL_DB_HOST','127.0.0.1')
DB_USER = os.getenv('LL_DB_USER','root')
DB_PASS = os.getenv('LL_DB_PASS','root')
DB_NAME = os.getenv('LL_DB_NAME','little_lemon')
POLL_SEC = float(os.getenv('LL_POLL_SEC','3'))

cn = mysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_NAME)
cur = cn.cursor(dictionary=True)

last_id = 0
print('Watching for changes...')
try:
    while True:
        cur.execute('SELECT * FROM change_log WHERE change_id > %s ORDER BY change_id ASC', (last_id,))
        rows = cur.fetchall()
        for r in rows:
            last_id = r['change_id']
            event = {'time': str(r['change_time']), 'entity': r['entity'], 'id': r['entity_id'], 'action': r['action']}
            print(json.dumps(event))
        time.sleep(POLL_SEC)
except KeyboardInterrupt:
    pass
finally:
    cur.close(); cn.close()
