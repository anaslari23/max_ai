import json
from typing import List, Dict

class ShortTermMemory:
    """In-memory short-term conversation storage (no Redis required)"""
    
    def __init__(self):
        self._memory_store = {}  # session_id -> list of messages
        print("ShortTermMemory: Using in-memory storage (no Redis)")

    async def add_message(self, session_id: str, role: str, content: str):
        message = {"role": role, "content": content}
        
        if session_id not in self._memory_store:
            self._memory_store[session_id] = []
        
        self._memory_store[session_id].append(message)
        
        # Keep only last 50 messages per session
        if len(self._memory_store[session_id]) > 50:
            self._memory_store[session_id] = self._memory_store[session_id][-50:]

    async def get_history(self, session_id: str, limit: int = 10) -> List[Dict[str, str]]:
        messages = self._memory_store.get(session_id, [])
        return messages[-limit:] if messages else []

    async def clear(self, session_id: str):
        if session_id in self._memory_store:
            del self._memory_store[session_id]

