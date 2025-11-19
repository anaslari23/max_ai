from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.skills.registry import SkillRegistry

@SkillRegistry.register
class PhoneSkill(BaseSkill):
    name = "call"
    description = "Initiate a phone call to a contact or number."

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        target = params.get("target")
        return {
            "status": "success",
            "message": f"Calling {target}...",
            "action_data": {
                "type": "call",
                "number": target
            }
        }
