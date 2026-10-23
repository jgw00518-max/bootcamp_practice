# -*- coding: utf-8 -*-

from fastapi import FastAPI, Request
from pydantic import BaseModel
import joblib
import pymysql

app = FastAPI()

class Student(BaseModel):
    code: str
    name: str
    dept: str
    phone: str
    address: str

class StudentCode(BaseModel):
    code: str


def connect():
    # MySQL Connection
    conn = pymysql.connect(
        host='192.168.20.71',
        user='root',
        password='qwer1234',
        database='education',
        charset='utf8'
    )
    return conn


@app.get("/select")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 결과값을 Dictionary로 변환
    result = [{'code' : row[0], 'name' : row[1], 'dept' : row[2], 'phone' : row[3], 'address' : "" if row[4] == None else row[4]} for row in rows]
    return {'results' : result}

@app.post("/insert")
async def insert(student: Student):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "insert into student(scode, sname, sdept, sphone, saddress) values (%s,%s,%s,%s,%s)"
        curs.execute(sql, (student.code, student.name, student.dept, student.phone, student.address))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    

@app.post("/update")
async def update(student: Student):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "update student set sname=%s, sdept=%s, sphone=%s, saddress=%s where scode=%s"
        curs.execute(sql, (student.name, student.dept, student.phone, student.address, student.code))
        conn.commit()
        conn.close()
        return {'result':'OK'}  
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}

@app.post("/delete")
async def delete(student: StudentCode):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "delete from student where scode = %s"
        curs.execute(sql, (student.code))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.20.71", port=8000)
