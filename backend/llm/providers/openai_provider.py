import openai
from typing import List, Dict, Any
from backend.llm.providers.base import LLMProvider
from backend.config.settings import settings
from backend.utils.logger import logger

class OpenAIProvider(LLMProvider):
    def __init__(self):
        self.client = openai.AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.model = "gpt-4-turbo-preview" # Default model

    async def generate_response(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None) -> str:
        messages = self._build_messages(prompt, system_prompt, history)
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=0.7
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"OpenAI generation error: {e}")
            return "I'm sorry, I encountered an error processing your request."

    async def generate_stream(self, prompt: str, system_prompt: str = None, history: List[Dict[str, str]] = None):
        messages = self._build_messages(prompt, system_prompt, history)
        try:
            stream = await self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                stream=True
            )
            async for chunk in stream:
                if chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content
        except Exception as e:
            logger.error(f"OpenAI streaming error: {e}")
            yield "Error generating response."

    def _build_messages(self, prompt: str, system_prompt: str, history: List[Dict[str, str]]) -> List[Dict[str, str]]:
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        if history:
            messages.extend(history)
            
        messages.append({"role": "user", "content": prompt})
        return messages
