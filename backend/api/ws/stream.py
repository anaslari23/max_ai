import json
from fastapi import WebSocket, WebSocketDisconnect, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from backend.db.session import get_db
from backend.llm.orchestrator import Orchestrator
from backend.memory.memory_controller import MemoryController
from backend.skills.registry import SkillRegistry
from backend.utils.logger import logger

# Note: In a real app, we would need a way to inject the DB session into the WS handler
# For simplicity, we'll instantiate dependencies manually or use a pattern to get them.

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    
    # Mock session/user for now
    session_id = "ws_session_123"
    user_id = 1 
    
    # We need to get a DB session. 
    # In production, use `async with SessionLocal() as db:`
    from backend.db.session import SessionLocal
    
    async with SessionLocal() as db:
        orchestrator = Orchestrator()
        memory_controller = MemoryController(db)
        
        try:
            while True:
                # Receive data (could be audio bytes or text JSON)
                data = await websocket.receive_text()
                
                # Assume JSON input for now: {"type": "text", "content": "..."}
                # or {"type": "audio", "content": "base64..."}
                try:
                    message = json.loads(data)
                except json.JSONDecodeError:
                    await websocket.send_text(json.dumps({"error": "Invalid JSON"}))
                    continue
                
                if message.get("type") == "text":
                    user_input = message.get("content")
                    
                    # 1. Get Context & History
                    context = await memory_controller.get_context(user_id, session_id, user_input)
                    history = await memory_controller.short_term.get_history(session_id)
                    skills = SkillRegistry.get_skill_names()
                    prefs = await memory_controller.profile.get_preferences(user_id)
                    
                    # 2. Process
                    result = await orchestrator.process(
                        user_input=user_input,
                        history=history,
                        preferences=prefs,
                        memory_context=context,
                        available_skills=skills
                    )
                    
                    # 3. Send Response
                    await websocket.send_text(json.dumps(result))
                    
                    # 4. Save History
                    await memory_controller.short_term.add_message(session_id, "user", user_input)
                    await memory_controller.short_term.add_message(session_id, "assistant", result["message"])
                    
                elif message.get("type") == "audio":
                    # STT Placeholder
                    await websocket.send_text(json.dumps({"info": "Audio received, STT not implemented yet."}))
                    
        except WebSocketDisconnect:
            logger.info("Client disconnected")
