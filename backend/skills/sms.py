from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.skills.registry import SkillRegistry

@SkillRegistry.register
class SMSSkill(BaseSkill):
    name = "sms"
    description = "Send an SMS message."

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        target = params.get("target")
        message = params.get("message")
        return {
            "status": "success",
            "message": f"Sending SMS to {target}: {message}",
            "action_data": {
                "type": "sms",
                "target": target,
                "body": message
            }
        }
