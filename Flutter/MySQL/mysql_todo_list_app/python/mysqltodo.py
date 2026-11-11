from fastapi import FastAPI, Form, HTTPException
import pymysql

app = FastAPI()


def connect():
    return pymysql.connect(
        host='192.168.20.52',
        user='root',
        password='qwer1234',
        database='todolist',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
    )


@app.get("/todos")
async def select_todos():
    """현재 Todo 목록을 최신 항목부터 조회한다."""
    conn = None

    try:
        conn = connect()
        with conn.cursor() as curs:
            curs.execute(
                """
                SELECT seq, title, todo_date
                FROM todos
                ORDER BY seq DESC
                """
            )
            rows = curs.fetchall()

        return {"results": rows}
    except pymysql.MySQLError as error:
        print("Select todos error:", error)
        raise HTTPException(status_code=500, detail="Todo 목록 조회에 실패했습니다.")
    finally:
        if conn is not None:
            conn.close()


@app.post("/todos")
async def insert_todo(title: str = Form(...)):
    """Form으로 받은 제목과 MySQL 서버의 현재 날짜를 저장한다."""
    normalized_title = title.strip()
    if not normalized_title:
        raise HTTPException(status_code=400, detail="제목을 입력해 주세요.")

    conn = None

    try:
        conn = connect()
        with conn.cursor() as curs:
            curs.execute(
                """
                INSERT INTO todos (title, todo_date)
                VALUES (%s, CURRENT_DATE())
                """,
                (normalized_title,),
            )
            todo_seq = curs.lastrowid

            curs.execute(
                """
                SELECT seq, title, todo_date
                FROM todos
                WHERE seq = %s
                """,
                (todo_seq,),
            )
            todo = curs.fetchone()

        conn.commit()
        return {"result": "OK", "todo": todo}
    except pymysql.MySQLError as error:
        if conn is not None:
            conn.rollback()
        print("Insert todo error:", error)
        raise HTTPException(status_code=500, detail="Todo 추가에 실패했습니다.")
    finally:
        if conn is not None:
            conn.close()


@app.post("/todos/delete")
async def delete_todo(seq: int = Form(...)):
    """Todo를 삭제 목록에 보관한 후 현재 목록에서 삭제한다."""
    conn = None

    try:
        conn = connect()
        with conn.cursor() as curs:
            curs.execute(
                """
                SELECT seq, title, todo_date
                FROM todos
                WHERE seq = %s
                FOR UPDATE
                """,
                (seq,),
            )
            todo = curs.fetchone()

            if todo is None:
                raise HTTPException(status_code=404, detail="Todo를 찾을 수 없습니다.")

            curs.execute(
                """
                INSERT INTO deleted_todos
                    (todo_seq, title, todo_date, delete_time)
                VALUES (%s, %s, %s, CURRENT_TIMESTAMP())
                """,
                (todo["seq"], todo["title"], todo["todo_date"]),
            )
            deleted_seq = curs.lastrowid

            curs.execute("DELETE FROM todos WHERE seq = %s", (seq,))

        conn.commit()
        return {"result": "OK", "deleted_seq": deleted_seq}
    except HTTPException:
        if conn is not None:
            conn.rollback()
        raise
    except pymysql.MySQLError as error:
        if conn is not None:
            conn.rollback()
        print("Delete todo error:", error)
        raise HTTPException(status_code=500, detail="Todo 삭제에 실패했습니다.")
    finally:
        if conn is not None:
            conn.close()


@app.get("/deleted-todos")
async def select_deleted_todos():
    """삭제된 Todo 목록을 최근 삭제 순서로 조회한다."""
    conn = None

    try:
        conn = connect()
        with conn.cursor() as curs:
            curs.execute(
                """
                SELECT seq, todo_seq, title, todo_date, delete_time
                FROM deleted_todos
                ORDER BY delete_time DESC, seq DESC
                """
            )
            rows = curs.fetchall()

        return {"results": rows}
    except pymysql.MySQLError as error:
        print("Select deleted todos error:", error)
        raise HTTPException(status_code=500, detail="삭제 목록 조회에 실패했습니다.")
    finally:
        if conn is not None:
            conn.close()


@app.post("/deleted-todos/restore")
async def restore_deleted_todo(seq: int = Form(...)):
    """삭제 Todo를 현재 목록에 다시 추가하고 삭제 목록에서 제거한다."""
    conn = None

    try:
        conn = connect()
        with conn.cursor() as curs:
            curs.execute(
                """
                SELECT seq, title, todo_date
                FROM deleted_todos
                WHERE seq = %s
                FOR UPDATE
                """,
                (seq,),
            )
            deleted_todo = curs.fetchone()

            if deleted_todo is None:
                raise HTTPException(
                    status_code=404,
                    detail="삭제된 Todo를 찾을 수 없습니다.",
                )

            curs.execute(
                """
                INSERT INTO todos (title, todo_date)
                VALUES (%s, %s)
                """,
                (deleted_todo["title"], deleted_todo["todo_date"]),
            )
            restored_seq = curs.lastrowid

            curs.execute("DELETE FROM deleted_todos WHERE seq = %s", (seq,))

        conn.commit()
        return {"result": "OK", "restored_seq": restored_seq}
    except HTTPException:
        if conn is not None:
            conn.rollback()
        raise
    except pymysql.MySQLError as error:
        if conn is not None:
            conn.rollback()
        print("Restore todo error:", error)
        raise HTTPException(status_code=500, detail="Todo 복구에 실패했습니다.")
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="192.168.20.52", port=8000)
