from typing import List, Dict
from backend.llm.providers.base import LLMProvider

class MemoryExtractor:
    def __init__(self, llm_provider: LLMProvider):
        self.llm = llm_provider

    async def extract_facts(self, conversation_history: List[Dict[str, str]]) -> List[str]:
        """
        Analyze conversation to extract new facts about the user.
        """
        # This would typically be a background job or a separate LLM call
        # For now, we return empty
        return []
