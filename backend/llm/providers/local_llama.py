import httpx
import json
from typing import List, Dict, Any, AsyncGenerator
from backend.llm.providers.base import LLMProvider
from backend.utils.logger import logger

class LocalLlamaProvider(LLMProvider):
    def __init__(self):
        self.base_url = "http://localhost:11434/api"
        self.model = "mistral" # Default to mistral, user can pull others
        logger.info(f"Initializing Local LLaMA Provider (Ollama) with model: {self.model}")

    async def generate_response(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None) -> str:
        url = f"{self.base_url}/generate"
        
        # Construct full prompt with history if needed
        # Ollama 'generate' endpoint takes a single prompt, or we can use 'chat' endpoint
        # Let's use 'chat' endpoint for better history handling if available, but 'generate' is simpler for raw text.
        # Actually, 'chat' is better for conversation.
        
        url = f"{self.base_url}/chat"
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
            
        if history:
            for msg in history:
                messages.append({"role": msg["role"], "content": msg["content"]})
                
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "stream": False
        }
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(url, json=payload, timeout=60.0)
                response.raise_for_status()
                result = response.json()
                return result.get("message", {}).get("content", "")
        except Exception as e:
            logger.error(f"Ollama connection failed: {e}")
            return "I am unable to reach my local brain (Ollama). Please ensure Ollama is running and you have pulled the 'mistral' model."

    async def generate_stream(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None) -> AsyncGenerator[str, None]:
        url = f"{self.base_url}/chat"
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
            
        if history:
            for msg in history:
                messages.append({"role": msg["role"], "content": msg["content"]})
                
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "stream": True
        }
        
        try:
            async with httpx.AsyncClient() as client:
                async with client.stream("POST", url, json=payload, timeout=60.0) as response:
                    async for line in response.aiter_lines():
                        if line:
                            try:
                                chunk = json.loads(line)
                                content = chunk.get("message", {}).get("content", "")
                                if content:
                                    yield content
                            except json.JSONDecodeError:
                                continue
        except Exception as e:
            logger.error(f"Ollama streaming failed: {e}")
            yield "Error connecting to local brain."
