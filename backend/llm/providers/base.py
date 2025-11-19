from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional

class LLMProvider(ABC):
    @abstractmethod
    async def generate_response(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None) -> str:
        """
        Generate a response from the LLM.
        """
        pass

    @abstractmethod
    async def generate_stream(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None):
        """
        Stream the response from the LLM.
        """
        pass
