import json
from typing import List, Dict
from redis.asyncio import Redis
from backend.config.settings import settings

class ShortTermMemory:
    def __init__(self):
        self.redis = Redis.from_url(settings.REDIS_URL, decode_responses=True)
        self.ttl = 3600  # 1 hour

    async def add_message(self, session_id: str, role: str, content: str):
        key = f"chat:{session_id}"
        message = json.dumps({"role": role, "content": content})
        await self.redis.rpush(key, message)
        await self.redis.expire(key, self.ttl)

    async def get_history(self, session_id: str, limit: int = 10) -> List[Dict[str, str]]:
        key = f"chat:{session_id}"
        messages = await self.redis.lrange(key, -limit, -1)
        return [json.loads(m) for m in messages]

    async def clear(self, session_id: str):
        await self.redis.delete(f"chat:{session_id}")
