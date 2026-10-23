# FastAPI
# python용 webserver

# Explorer
# ㄴ FastApI


# vs code Terminal에서 다음과 같이 실행

# > conda env list => base 확인
# > conda activate base => base 활성화 하여 install 등을 실행하면 base 환경의 Python과 패키지 사용
# > pip install fastapi => FastAPI 설치
# > pip install uvicorn => python용 webserver 설치
# -------------------------------------------------------------------------
# fastapi_01.py 파일 생성

# ctrl + shift + p

# Python Select Interpreter -> base 선택
# -------------------------------------------------------------------------
from fastapi import FastAPI

app = FastAPI()

@app.get("/") # 무작정 실행
async def read_root():
    return {"message" : "Hello, World!"}

@app.get("/items/{item_id}") # {}안의 내용을 받아옴
async def read_item(item_id: int, query_param: str = None): # int, str type으로 설정
    return {'item_id' : item_id, 'query_param' : query_param}

if __name__ == "__main__":  # flutter로 치면 main 함수
    import uvicorn
    uvicorn.run(app, host="192.168.20.52", port=8000) # 개인 IPv4 주소, port 번호는 보통 8000


# -------------------------------------------------------------------------
# - 파일 내용 작성 후 run -> Terminal에 있는 http://(ip 주소):8000이 실행 중인 서버 주소
# (terminal에서 ctrl + c => 서버 끄기)
# (terminal에서 화살표 윗 방향키 후 enter로도 실행 가능)

# - http://(ip 주소):8000/docs 확인해보기 (중요, 포트폴리오에 캡쳐 후 작성 가능)
# GET -> Try it out -> Execute

# - http://(ip 주소):8000/items/(원하는숫자)
# 주소로 들어가면 입력한 숫자 출력