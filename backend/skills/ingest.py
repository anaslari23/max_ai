import httpx
from typing import Dict, Any
from backend.skills.base import BaseSkill
from backend.memory.long_term import LongTermMemory

class IngestSkill(BaseSkill):
    name = "ingest"
    description = "Ingest a dataset or text from a URL into long-term memory. Use this to 'learn' from a file."
    parameters = {
        "type": "object",
        "properties": {
            "url": {
                "type": "string",
                "description": "URL to a raw text, JSON, or CSV file."
            },
            "text": {
                "type": "string",
                "description": "Direct text content to ingest."
            },
            "dataset_name": {
                "type": "string",
                "description": "Name of a preset dataset to ingest. Options: 'prompts', 'linux', 'python'. Use this if the user asks to ingest 'prompts' or 'linux cheatsheet'."
            },
            "chunk_size": {
                "type": "integer",
                "description": "Number of characters per chunk.",
                "default": 500
            }
        },
        "oneOf": [
            {"required": ["url"]},
            {"required": ["text"]},
            {"required": ["dataset_name"]}
        ]
    }

    def __init__(self):
        self.long_term_memory = LongTermMemory()
        self.presets = {
            "prompts": "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
            "linux": "https://raw.githubusercontent.com/tldr-pages/tldr/main/pages/linux/ls.md", # Example
            "python": "https://raw.githubusercontent.com/gto76/python-cheatsheet/master/README.md"
        }

    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        url = params.get("url")
        text = params.get("text")
        dataset_name = params.get("dataset_name")
        
        # Handle presets
        if dataset_name and dataset_name.lower() in self.presets:
            url = self.presets[dataset_name.lower()]
        elif url and url.lower() in self.presets:
             url = self.presets[url.lower()]
            
        chunk_size = params.get("chunk_size", 500)
        user_id = "1" # Default user

        content = ""
        source = "direct_text"

        if url:
            source = url
            try:
                async with httpx.AsyncClient() as client:
                    response = await client.get(url, follow_redirects=True)
                    response.raise_for_status()
                    content = response.text
            except Exception as e:
                return {"error": f"Failed to fetch URL: {e}"}
        elif text:
            content = text
        else:
            return {"error": "No URL or text provided."}

        # Simple chunking strategy
        chunks = [content[i:i+chunk_size] for i in range(0, len(content), chunk_size)]
        
        count = 0
        for chunk in chunks:
            if not chunk.strip():
                continue
            await self.long_term_memory.save(user_id, chunk, {"source": source, "type": "ingested"})
            count += 1

        return {
            "status": "success",
            "message": f"Successfully ingested {count} chunks from {source}.",
            "data": {"chunks_count": count, "source": source}
        }
