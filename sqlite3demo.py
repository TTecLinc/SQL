# -*- coding: utf-8 -*-
"""
Created on Tue Aug 18 07:57:41 2020

@author: Peilin Yang
"""

import sqlite3 as sql

con=sql.connect('demo.db')

cur=con.cursor()

sql='''CREATE TABLE t_person(
        pno INTEGER PRIMARY KEY AUTOINCREMENT,
        pname VARCHAR NOT NULL,
        age INTEGER)
'''

try:
    cur.execute(sql)
    print('ok')
except Exception as e:
    print(e)
    print('not ok')
finally:
    cur.close()
    con.close()


con=sql.connect('demo.db')

cur=con.cursor()
sql2='''
   INSERT INTO t_person(pname,age) values(?,?);
   UPDARTE t_person SET pname=? WHERE pno=?;
   DELETE FROM t_person WHERE pno=?
'''

try:
    cur.execute(sql2,('DY',24))
    # if there only exist one element in the tuple then add a comma
    # but in pymysql it is not necessary
    cur.execute(sql2,(1,))
    con.commit()
except Exception as e:
    print(e)
    con.rollback()
finally:
    cur.close()
    con.close()
    
    
sql='select * from t_person'
try:
    cur.excute(sql)
    per=cur.fetchall()
    for p in per:
        print(p)
except Exception as e:
    print(e)
finally:
    cur.close()
    con.close()
    
    
