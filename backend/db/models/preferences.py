from sqlalchemy import Column, Integer, String, ForeignKey, JSON
from sqlalchemy.orm import relationship
from backend.db.session import Base

class Preferences(Base):
    __tablename__ = "preferences"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    
    # AI Persona settings
    persona_name = Column(String, default="Assistant")
    persona_style = Column(String, default="helpful") # formal, casual, witty
    
    # Voice settings
    voice_id = Column(String, default="default")
    voice_speed = Column(Integer, default=1)
    
    # System permissions (JSON list of allowed skills)
    allowed_skills = Column(JSON, default=[])
    
    user = relationship("User", back_populates="preferences")
