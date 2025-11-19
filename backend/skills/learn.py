from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.memory.long_term import LongTermMemory

class LearnSkill(BaseSkill):
    name = "learn"
    description = "Save a new fact or correction to long-term memory. Use this when the user explicitly asks you to remember something or corrects a mistake."
    parameters = {
        "type": "object",
        "properties": {
            "fact": {
                "type": "string",
                "description": "The fact or information to be remembered."
            },
            "category": {
                "type": "string",
                "description": "Optional category (e.g., 'personal', 'correction', 'preference').",
                "default": "general"
            }
        },
        "required": ["fact"]
    }

    def __init__(self):
        self.long_term_memory = LongTermMemory()

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        fact = params.get("fact")
        category = params.get("category", "general")
        
        # In a real implementation, we would get the user_id from the context
        # For now, we'll assume a default user_id or pass it in params if possible
        # Since BaseSkill doesn't have user_id, we might need to hack it or update the interface
        # For this MVP, we'll use a default user_id "1" as used in other places
        user_id = "1" 
        
        if not fact:
            return {"error": "No fact provided to learn."}

        # Save to Vector DB
        # We prefix with [LEARNED] to easily identify it later
        content = f"[LEARNED] [{category.upper()}] {fact}"
        await self.long_term_memory.save(user_id, content, {"type": "fact", "category": category})
        
        return {
            "status": "success",
            "message": f"I have committed this to memory: {fact}",
            "data": {"fact": fact, "category": category}
        }
