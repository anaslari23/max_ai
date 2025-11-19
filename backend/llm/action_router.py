from typing import Dict, Any, Optional
from backend.utils.parsers import extract_json_from_text
from backend.utils.logger import logger

class ActionRouter:
    def parse_action(self, llm_response: str) -> Dict[str, Any]:
        """
        Parses the LLM response to check for structured actions.
        Returns a dictionary with 'message' and optional 'action'.
        """
        data = extract_json_from_text(llm_response)
        
        if data and "action" in data:
            action_name = data['action']['name']
            
            # Validate against registry
            from backend.skills.registry import SkillRegistry
            if not SkillRegistry.get_skill(action_name):
                logger.warning(f"LLM hallucinated unknown action: {action_name}. Ignoring.")
                return {
                    "message": data.get("message", llm_response),
                    "action": None
                }

            logger.info(f"Action detected: {action_name}")
            return data
        
        # If no JSON found or no action, treat entire response as message
        return {
            "message": llm_response,
            "action": None
        }
