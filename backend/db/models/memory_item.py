from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.db.session import Base

class MemoryItem(Base):
    __tablename__ = "memory_items"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Content of the memory
    content = Column(Text, nullable=False)
    
    # Type: 'conversation', 'fact', 'summary', 'action'
    memory_type = Column(String, index=True, default="fact")
    
    # Metadata for context (e.g. source, confidence, tags)
    metadata_json = Column(JSON, default={})
    
    # Vector DB ID reference if stored in Milvus/Pinecone
    vector_id = Column(String, nullable=True, index=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="memories")
