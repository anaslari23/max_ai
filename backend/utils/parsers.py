import json
import re
from typing import Any, Dict, Optional
from backend.utils.logger import logger

def extract_json_from_text(text: str) -> Optional[Dict[str, Any]]:
    """
    Extracts JSON from a string, handling markdown code blocks.
    """
    try:
        # Try direct parsing first
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Look for markdown code blocks
    pattern = r"```json\s*(.*?)\s*```"
    match = re.search(pattern, text, re.DOTALL)
    if match:
        json_str = match.group(1)
        try:
            return json.loads(json_str)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from markdown block: {e}")
            return None
            
    # Fallback: Try to find the first { and last }
    try:
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1:
            json_str = text[start:end+1]
            return json.loads(json_str)
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON via fallback: {e}")
        
    return None
