from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.db.session import get_db
from backend.memory.memory_controller import MemoryController
from pydantic import BaseModel

router = APIRouter()

class MemoryQuery(BaseModel):
    user_id: int
    query: str

@router.post("/search")
async def search_memory(query: MemoryQuery, db: AsyncSession = Depends(get_db)):
    controller = MemoryController(db)
    results = await controller.long_term.search(str(query.user_id), query.query)
    return {"results": results}
