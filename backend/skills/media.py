from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.skills.registry import SkillRegistry

@SkillRegistry.register
class MediaSkill(BaseSkill):
    name = "media"
    description = "Control media playback."

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        command = params.get("command") # play, pause, next, previous
        return {
            "status": "success",
            "message": f"Media command: {command}",
            "action_data": {
                "type": "media",
                "command": command
            }
        }
