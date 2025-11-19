import json
import os
import httpx
import numpy as np
from typing import List, Dict, Any
from backend.config.settings import settings
from backend.utils.logger import logger

class LongTermMemory:
    def __init__(self):
        self.memory_file = "local_memory.json"
        self.ollama_url = "http://localhost:11434/api/embeddings"
        self.model = "mistral" # Must match the model used for generation usually, or use a specific embed model
        
        # Load existing memory
        if os.path.exists(self.memory_file):
            try:
                with open(self.memory_file, "r") as f:
                    self.memories = json.load(f)
            except:
                self.memories = []
        else:
            self.memories = []
            
        logger.info(f"Initialized Local Vector Store with {len(self.memories)} items.")

    async def get_embedding(self, text: str) -> List[float]:
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.ollama_url, 
                    json={"model": self.model, "prompt": text},
                    timeout=30.0
                )
                if response.status_code == 200:
                    return response.json().get("embedding", [])
                else:
                    logger.error(f"Ollama embedding failed: {response.text}")
                    return []
        except Exception as e:
            logger.error(f"Ollama embedding error: {e}")
            return []

    async def save(self, user_id: str, content: str, metadata: Dict[str, Any] = None):
        """
        Embed and save a memory snippet.
        """
        embedding = await self.get_embedding(content)
        if not embedding:
            logger.warning("Could not generate embedding, saving without vector.")
            
        memory_item = {
            "user_id": user_id,
            "content": content,
            "metadata": metadata or {},
            "embedding": embedding,
            "timestamp": 0 # TODO: Add timestamp
        }
        
        self.memories.append(memory_item)
        self._save_to_disk()
        logger.info(f"Saved to long-term memory: {content[:50]}...")

    async def search(self, user_id: str, query: str, limit: int = 3) -> List[str]:
        """
        Retrieve relevant memories using cosine similarity.
        """
        query_embedding = await self.get_embedding(query)
        if not query_embedding:
            return []
            
        # Calculate cosine similarity
        # Sim(A, B) = (A . B) / (||A|| * ||B||)
        
        scored_memories = []
        vec_a = np.array(query_embedding)
        norm_a = np.linalg.norm(vec_a)
        
        if norm_a == 0:
            return []
            
        for mem in self.memories:
            if not mem.get("embedding"):
                continue
                
            vec_b = np.array(mem["embedding"])
            norm_b = np.linalg.norm(vec_b)
            
            if norm_b == 0:
                continue
                
            similarity = np.dot(vec_a, vec_b) / (norm_a * norm_b)
            scored_memories.append((similarity, mem["content"]))
            
        # Sort by similarity desc
        scored_memories.sort(key=lambda x: x[0], reverse=True)
        
        return [m[1] for m in scored_memories[:limit]]

    def _save_to_disk(self):
        try:
            with open(self.memory_file, "w") as f:
                json.dump(self.memories, f)
        except Exception as e:
            logger.error(f"Failed to save memory to disk: {e}")
