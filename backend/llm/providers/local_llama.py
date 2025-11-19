from typing import List, Dict, Any
from backend.llm.providers.base import LLMProvider
from backend.utils.logger import logger

class LocalLlamaProvider(LLMProvider):
    def __init__(self):
        # Initialize local model connection (e.g., via llama.cpp or ollama)
        logger.info("Initializing Local LLaMA Provider...")
        pass

    async def generate_response(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None) -> str:
        # Mock response for when no API keys are present
        logger.warning("Using Local LLaMA Mock Provider (No API Key set)")
        
        lower_prompt = prompt.lower()
        if "call" in lower_prompt:
            return """{
  "message": "Calling now, sir.",
  "action": {
    "name": "call",
    "params": { "target": "Mom" },
    "needs_confirmation": false
  }
}"""
        elif "search" in lower_prompt:
             return """{
  "message": "Searching the web for you.",
  "action": {
    "name": "search",
    "params": { "query": "latest news" },
    "needs_confirmation": false
  }
}"""
        
        return "I am running in offline mode. Please set your OpenAI or Gemini API key in the .env file to unlock my full potential, Sir."

    async def generate_stream(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None):
        response = await self.generate_response(prompt, system_prompt, history)
        yield response
