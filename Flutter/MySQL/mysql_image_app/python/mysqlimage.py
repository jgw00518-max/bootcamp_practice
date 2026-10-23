from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import Response
import pymysql

app = FastAPI()

def connect():
    return pymysql.connect(
        host='192.168.20.52',
        user='root',
        password='qwer1234',
        database='python',
        charset='utf8'
    )

@app.post("/upload")
async def upload(
    name: str = Form(...), 
    phone: str = Form(...), 
    address: str = Form(...),
    relation: str = Form(...),
    file: UploadFile = File(...)):

    try:
        image_data = await file.read()
        conn = connect()
        curs = conn.cursor()
        sql = """
                INSERT INTO address (name, phone, address, relation, image)
                VALUES (%s, %s, %s, %s, %s)
            """
        curs.execute(sql, (name, phone, address, relation, image_data))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as e:
        print("Error:", e)
        return {'result':'Error'}

@app.post("/update")
async def update(
    seq: int = Form(...),
    name: str = Form(...),
    phone: str = Form(...),
    address: str = Form(...),
    relation: str = Form(...),
    file: UploadFile = File(None),
):
    try:
        conn = connect()
        curs = conn.cursor()

        if file is not None:
            image_data = await file.read()

            sql = """
                    UPDATE address
                    SET name = %s, phone = %s, address = %s, relation = %s, image = %s
                    WHERE seq = %s
                """

            curs.execute(sql, (name, phone, address, relation, image_data, seq))
        else:
            sql = """
                    UPDATE address
                    SET name = %s, phone = %s, address = %s, relation = %s
                    WHERE seq = %s
                """

            curs.execute(sql,(name, phone, address, relation, seq,),)
        conn.commit()
        conn.close()

        return {'result': 'OK'}

    except Exception as e:
        print("Error:", e)
        return {'result': 'Error'}

@app.post("/delete")
async def delete(seq: int = Form(...)):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = """
                DELETE FROM address
                WHERE seq = %s
            """
        curs.execute(sql, (seq,))
        conn.commit()
        conn.close()
        return {'result': 'OK'}
    except Exception as e:
        print("Error:", e)
        return {'result': 'Error'}



@app.get("/select")
async def select():
    conn = connect()
    curs = conn.cursor()
    curs.execute("SELECT seq, name, phone, address, relation FROM address ORDER BY name")
    rows = curs.fetchall()
    conn.close()
    result = [{'seq': row[0], 'name': row[1], 'phone': row[2], 'address': row[3], 'relation': row[4]} for row in rows]
    return {'results' : result}

@app.get("/view/{seq}")
async def view(seq: int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT image FROM address WHERE seq = %s", (seq,))
        row = curs.fetchone()
        conn.close()
        if row and row[0]:
            return Response(
                content=row[0],
                media_type='image/jpeg',
                headers={"Cache-Control":"no-cache, no-store, must-revalidate"}
            )
        else:
            return {'result' : 'No image found'}
    except Exception as e:
        print("Error", e)
        return{'result':'Error'}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host='192.168.20.52', port=8000)
