from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from backend.db.models.user import User
from backend.db.models.preferences import Preferences

class ProfileMemory:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_preferences(self, user_id: int) -> Preferences:
        result = await self.db.execute(select(Preferences).where(Preferences.user_id == user_id))
        prefs = result.scalars().first()
        if not prefs:
            # Create default
            prefs = Preferences(user_id=user_id)
            self.db.add(prefs)
            await self.db.commit()
            await self.db.refresh(prefs)
        return prefs

    async def update_preferences(self, user_id: int, updates: dict):
        prefs = await self.get_preferences(user_id)
        for key, value in updates.items():
            setattr(prefs, key, value)
        await self.db.commit()
        await self.db.refresh(prefs)
        return prefs
