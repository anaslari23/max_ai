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
            
            # Return a structured response that the Orchestrator can use
            return {
                "status": "success",
                "message": f"Search Results for '{query}':\n\n{summary}",
                "data": {
                    "results": formatted_results,
                    "summary": summary
                }
            }
        except Exception as e:
            return {
                "status": "error",
                "message": f"Failed to search: {str(e)}",
                "action_data": None
            }
