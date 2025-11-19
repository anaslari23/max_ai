from fastapi import APIRouter
from backend.skills.registry import SkillRegistry

router = APIRouter()

@router.get("/")
async def list_skills():
    skills = SkillRegistry.get_all_skills()
    return [{"name": s.name, "description": s.description} for s in skills]
