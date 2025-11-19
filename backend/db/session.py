from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from backend.config.settings import settings
import logging
import os

logger = logging.getLogger(__name__)

# Global variables
engine = None
SessionLocal = None

async def init_db_engine():
    global engine, SessionLocal
    
    # 1. Try PostgreSQL first
    try:
        logger.info(f"Attempting to connect to PostgreSQL...")
        # Create a temporary engine to test connection
        test_engine = create_async_engine(settings.DATABASE_URL, echo=False)
        async with test_engine.connect() as conn:
            await conn.execute("SELECT 1")
        
        # If successful, use it
        engine = test_engine
        logger.info("Connected to PostgreSQL successfully.")
        
    except Exception as e:
        logger.warning(f"PostgreSQL connection failed: {e}")
        logger.warning("Falling back to SQLite database.")
        
        # 2. Fallback to SQLite
        sqlite_url = "sqlite+aiosqlite:///./max_ai.db"
        engine = create_async_engine(sqlite_url, echo=False)
        
        # Ensure tables exist for SQLite
        # Use the Base defined in this file
        # Import all models here to ensure they are registered with Base.metadata
        from backend.db.models.user import User
        from backend.db.models.preferences import Preferences
        from backend.db.models.memory_item import MemoryItem
        
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
            
    SessionLocal = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

Base = declarative_base()

async def get_db():
    global SessionLocal
    if SessionLocal is None:
        await init_db_engine()
        
    async with SessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
