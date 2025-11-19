from typing import Dict, Any
from backend.skills.base import BaseSkill
import requests

class WeatherSkill(BaseSkill):
    name = "weather"
    description = "Get current weather information for a location. Use this when the user asks about weather."
    parameters = {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "City name or location (e.g., 'Tokyo', 'New York')"
            }
        },
        "required": ["location"]
    }

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        location = params.get("location", "")
        
        if not location:
            return {"error": "No location provided"}
        
        try:
            # Using wttr.in for simple weather data (no API key needed)
            url = f"https://wttr.in/{location}?format=%C+%t+%h+%w"
            response = requests.get(url, timeout=5)
            
            if response.status_code == 200:
                weather_data = response.text.strip()
                return {
                    "status": "success",
                    "message": f"Weather in {location}: {weather_data}",
                    "data": {"location": location, "weather": weather_data}
                }
            else:
                return {
                    "status": "error",
                    "message": f"Could not fetch weather for {location}",
                    "data": None
                }
        except Exception as e:
            return {
                "status": "error",
                "message": f"Weather service error: {str(e)}",
                "data": None
            }
