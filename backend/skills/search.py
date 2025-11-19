from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.skills.registry import SkillRegistry
from googlesearch import search

@SkillRegistry.register
class SearchSkill(BaseSkill):
    name = "search"
    description = "Search the web for information using Google."

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        query = params.get("query")
        try:
            # Perform search, get top 3 results
            results = list(search(query, num_results=3, advanced=True))
            formatted_results = []
            for res in results:
                formatted_results.append(f"Title: {res.title}\nURL: {res.url}\nDescription: {res.description}")
            
            summary = "\n\n".join(formatted_results)
            
            return {
                "status": "success",
                "message": f"Here is what I found for '{query}':\n\n{summary}",
                "action_data": {
                    "type": "search",
                    "query": query,
                    "results": formatted_results
                }
            }
        except Exception as e:
            return {
                "status": "error",
                "message": f"Failed to search: {str(e)}",
                "action_data": None
            }
