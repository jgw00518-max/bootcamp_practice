# main으로 쓸 fastapi (실행용)
# 각 팀원에게 경로를 따로 주어 각각 다른 파일에서 작업 후 호출
# 각각 따로 파일을 만들어 사용해야 Git에서 충돌이 일어나지 않음

from fastapi import FastAPI
from items import router as items_router

app = FastAPI()
app.include_router(items_router, prefix='/items', tags=['items']) 
                                # prefix : 주소 뒤에 /items 가 들어오면 items_router로 보내기

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.20.52", port=8000)
