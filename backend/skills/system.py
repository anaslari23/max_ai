from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.skills.registry import SkillRegistry

@SkillRegistry.register
class SystemSkill(BaseSkill):
    name = "system"
    description = "System level controls (volume, brightness, etc)."

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        setting = params.get("setting")
        value = params.get("value")
        return {
            "status": "success",
            "message": f"Setting {setting} to {value}",
            "action_data": {
                "type": "system",
                "setting": setting,
                "value": value
            }
        }
