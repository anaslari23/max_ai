from typing import List, Dict
from sqlalchemy.ext.asyncio import AsyncSession
from backend.memory.short_term import ShortTermMemory
from backend.memory.long_term import LongTermMemory
from backend.memory.profile import ProfileMemory
from backend.memory.extractor import MemoryExtractor

class MemoryController:
    def __init__(self, db: AsyncSession):
        self.short_term = ShortTermMemory()
        self.long_term = LongTermMemory()
        self.profile = ProfileMemory(db)
        # self.extractor = MemoryExtractor(...) 

    async def get_context(self, user_id: int, session_id: str, query: str) -> str:
        """
        Aggregates context from all memory sources.
        """
        # 1. Get recent history
        history = await self.short_term.get_history(session_id)
        
        # 2. Get relevant long-term memories
        relevant_memories = await self.long_term.search(str(user_id), query)
        
        # 3. Get profile/preferences
        prefs = await self.profile.get_preferences(user_id)
        
        context = f"User Persona: {prefs.persona_name}\n"
        context += "Relevant Memories:\n" + "\n".join(relevant_memories) + "\n"
        context += "Recent Conversation:\n" + "\n".join([f"{m['role']}: {m['content']}" for m in history])
        
        return context
