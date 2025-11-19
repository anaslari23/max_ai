import google.generativeai as genai
from typing import List, Dict, Any
from backend.llm.providers.base import LLMProvider
from backend.config.settings import settings
from backend.utils.logger import logger

class GeminiProvider(LLMProvider):
    def __init__(self):
        if settings.GEMINI_API_KEY:
            genai.configure(api_key=settings.GEMINI_API_KEY)
            self.model = genai.GenerativeModel('gemini-pro')
        else:
            logger.warning("Gemini API Key not found.")

    async def generate_response(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None) -> str:
        # Note: Gemini handling of system prompts and history is slightly different
        # For simplicity, we'll prepend system prompt to the first message or use chat history
        chat = self.model.start_chat(history=self._convert_history(history))
        
        full_prompt = prompt
        if system_prompt:
            full_prompt = f"System Instruction: {system_prompt}\n\nUser: {prompt}"
            
        try:
            response = await chat.send_message_async(full_prompt)
            return response.text
        except Exception as e:
            logger.error(f"Gemini generation error: {e}")
            return "Error generating response."

    async def generate_stream(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None):
        chat = self.model.start_chat(history=self._convert_history(history))
        
        full_prompt = prompt
        if system_prompt:
            full_prompt = f"System Instruction: {system_prompt}\n\nUser: {prompt}"

        try:
            response = await chat.send_message_async(full_prompt, stream=True)
            async for chunk in response:
                yield chunk.text
        except Exception as e:
            logger.error(f"Gemini streaming error: {e}")
            yield "Error generating response."

    def _convert_history(self, history: List[Dict[str, str]]) -> List[Dict[str, str]]:
        # Convert standard format to Gemini format if needed
        # Gemini uses 'user' and 'model' roles
        gemini_history = []
        if not history:
            return []
            
        for msg in history:
            role = "user" if msg["role"] == "user" else "model"
            gemini_history.append({"role": role, "parts": [msg["content"]]})
        return gemini_history
