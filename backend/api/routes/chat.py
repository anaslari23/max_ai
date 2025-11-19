from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from typing import List, Optional
from backend.db.session import get_db
from backend.llm.orchestrator import Orchestrator
from backend.memory.memory_controller import MemoryController
from backend.skills.registry import SkillRegistry

router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    session_id: str
    user_id: int # In real app, get from auth token

class ChatResponse(BaseModel):
    response: str
    action: Optional[dict] = None

@router.post("/message", response_model=ChatResponse)
async def send_message(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    orchestrator = Orchestrator()
    memory_controller = MemoryController(db)
    
    # 1. Get Context
    context = await memory_controller.get_context(request.user_id, request.session_id, request.message)
    
    # 2. Get History
    history = await memory_controller.short_term.get_history(request.session_id)
    
    # 3. Get Skills
    skills = SkillRegistry.get_skill_names()
    
    # 4. Get Preferences
    prefs = await memory_controller.profile.get_preferences(request.user_id)
    
    # 5. Process
    result = await orchestrator.process(
        user_input=request.message,
        history=history,
        preferences=prefs,
        memory_context=context,
        available_skills=skills
    )
    
    # 6. Save to History
    await memory_controller.short_term.add_message(request.session_id, "user", request.message)
    await memory_controller.short_term.add_message(request.session_id, "assistant", result["message"])
    
    return ChatResponse(response=result["message"], action=result.get("action"))
