from typing import Dict, Any
from backend.skills.base import BaseSkill

class TimerSkill(BaseSkill):
    name = "timer"
    description = "Set a timer for a specified duration. Use this when the user asks to set a timer or reminder."
    parameters = {
        "type": "object",
        "properties": {
            "duration": {
                "type": "string",
                "description": "Duration in natural language (e.g., '5 minutes', '1 hour', '30 seconds')"
            },
            "label": {
                "type": "string",
                "description": "Optional label for the timer (e.g., 'pizza', 'meeting')",
                "default": ""
            }
        },
        "required": ["duration"]
    }

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        duration = params.get("duration", "")
        label = params.get("label", "")
        
        if not duration:
            return {"error": "No duration provided"}
        
        # This is a client-side action - the mobile app will handle the actual timer
        # We just return the instruction
        message = f"Setting timer for {duration}"
        if label:
            message += f" ({label})"
        
        return {
            "status": "success",
            "message": message,
            "data": {
                "duration": duration,
                "label": label,
                "action_type": "set_timer"
            }
        }
