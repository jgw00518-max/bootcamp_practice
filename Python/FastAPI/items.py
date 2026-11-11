# 팀플 시 각 팀원이 사용할 router 예시

from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def read_items():
    return {'message' : "read all items"}

@router.get("/{item_id}")
async def read_items(item_id: int):
    return {'item_id' : item_id}