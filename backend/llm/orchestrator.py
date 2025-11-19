from typing import List, Dict, Any
from backend.llm.providers.openai_provider import OpenAIProvider
from backend.llm.providers.gemini_provider import GeminiProvider
from backend.llm.providers.local_llama import LocalLlamaProvider
from backend.llm.prompt_builder import PromptBuilder
from backend.llm.action_router import ActionRouter
from backend.config.settings import settings
from backend.db.models.preferences import Preferences

class Orchestrator:
    def __init__(self):
        self.providers = {
            "openai": OpenAIProvider(),
            "gemini": GeminiProvider(),
            "local": LocalLlamaProvider()
        }
        self.default_provider = "openai" if settings.OPENAI_API_KEY else "gemini"
        self.prompt_builder = PromptBuilder()
        self.action_router = ActionRouter()

    async def process(self, user_input: str, history: List[Dict[str, str]], preferences: Preferences, memory_context: str, available_skills: List[str]) -> Dict[str, Any]:
        # 1. Build System Prompt
        system_prompt = self.prompt_builder.build(user_input, preferences, memory_context, available_skills)
        
        # 2. Select Provider
        provider_name = "openai" if settings.OPENAI_API_KEY and not settings.OPENAI_API_KEY.startswith("sk-...") else "gemini"
        if provider_name == "gemini" and (not settings.GEMINI_API_KEY or settings.GEMINI_API_KEY == "..."):
            provider_name = "local"
            
        provider = self.providers.get(provider_name, self.providers["local"])
        
        # 3. Generate Response (Re-Act Loop)
        max_turns = 3
        current_turn = 0
        
        while current_turn < max_turns:
            current_turn += 1
            
            try:
                raw_response = await provider.generate_response(user_input, system_prompt, history)
            except Exception as e:
                logger.error(f"Provider {provider_name} failed: {e}. Falling back to Local.")
                raw_response = await self.providers["local"].generate_response(user_input, system_prompt, history)
            
            # 4. Parse Action
            result = self.action_router.parse_action(raw_response)
            
            # Check if it's a server-side action (like search or weather)
            if result.get("action") and result["action"]["name"] in ["search", "weather"]:
                logger.info(f"Executing server-side action: {result['action']['name']}")
                
                # Execute the skill
                from backend.skills.registry import SkillRegistry
                skill = SkillRegistry.get_skill(result["action"]["name"])
                if skill:
                    skill_result = await skill.execute(result["action"]["params"])
                    
                    # Add observation to history/context for the next turn
                    observation = f"SYSTEM OBSERVATION: {skill_result['message']}"
                    history.append({"role": "system", "content": observation})
                    
                    # Continue the loop to let LLM answer based on observation
                    continue
            
            # If not a server-side action, or if we're done, return the result
            return result
            
        return result

    async def process_stream(self, user_input: str, history: List[Dict[str, str]], preferences: Preferences, memory_context: str, available_skills: List[str]):
        # Streaming is trickier with JSON actions. 
        # Strategy: Stream text until we detect JSON start, then buffer? 
        # Or just stream everything and let frontend handle it?
        # For now, we'll stream raw chunks.
        
        system_prompt = self.prompt_builder.build(user_input, preferences, memory_context, available_skills)
        provider_name = "openai"
        provider = self.providers.get(provider_name, self.providers[self.default_provider])
        
        async for chunk in provider.generate_stream(user_input, system_prompt, history):
            yield chunk
