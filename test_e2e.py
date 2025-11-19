import asyncio
import json
from backend.llm.orchestrator import Orchestrator
from backend.llm.orchestrator import Orchestrator
from backend.db.models.preferences import Preferences
from backend.db.models.user import User
from backend.db.models.memory_item import MemoryItem # Ensure MemoryItem is registered
from backend.skills.registry import SkillRegistry

# Mock dependencies
class MockPreferences(Preferences):
    persona_name = "Max"
    persona_style = "helpful and witty"

async def test_e2e_flow():
    print("Starting E2E Test...")
    
    # 1. Setup
    orchestrator = Orchestrator()
    user_input = "Call Mom"
    history = []
    preferences = MockPreferences()
    memory_context = "User's mom is named Sarah. Phone number: 555-0199."
    available_skills = SkillRegistry.get_skill_names()
    
    print(f"User Input: {user_input}")
    print(f"Context: {memory_context}")
    
    # 2. Process
    # Note: This requires a valid API Key in .env for OpenAI/Gemini to work fully.
    # If no key is present, it might fail or use a fallback if implemented.
    try:
        result = await orchestrator.process(
            user_input=user_input,
            history=history,
            preferences=preferences,
            memory_context=memory_context,
            available_skills=available_skills
        )
        
        print("\n--- Result ---")
        print(f"Message: {result['message']}")
        print(f"Action: {result.get('action')}")
        
        if result.get('action') and result['action']['name'] == 'call':
            print("\nSUCCESS: Action 'call' was correctly triggered.")
        else:
            print("\nWARNING: Action 'call' was NOT triggered. Check LLM response.")
            
    except Exception as e:
        print(f"\nERROR: {e}")
        print("Ensure you have set OPENAI_API_KEY or GEMINI_API_KEY in .env")

if __name__ == "__main__":
    asyncio.run(test_e2e_flow())
