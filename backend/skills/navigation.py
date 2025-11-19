from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.skills.registry import SkillRegistry

@SkillRegistry.register
class NavigationSkill(BaseSkill):
    name = "navigation"
    description = "Navigate to a destination."

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        destination = params.get("destination")
        return {
            "status": "success",
            "message": f"Navigating to {destination}...",
            "action_data": {
                "type": "navigation",
                "destination": destination
            }
        }
