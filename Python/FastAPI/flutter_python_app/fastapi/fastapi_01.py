from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message" : "Hello, World!"}

@app.get("/items/{item_id}")
async def read_item(item_id: int, query_param: str = None):
    return {'item_id' : item_id, 'query_param' : query_param}

@app.get("/mul/{number}")
async def mul_number(number: int):
    result = number * 10
    return {"input": number, "result": result}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.20.52", port=8000)