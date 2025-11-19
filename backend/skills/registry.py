from typing import Dict, Type, List
from backend.skills.base import BaseSkill
from backend.utils.logger import logger

class SkillRegistry:
    _skills: Dict[str, BaseSkill] = {}

    @classmethod
    def register(cls, skill_cls: Type[BaseSkill]):
        skill_instance = skill_cls()
        cls._skills[skill_instance.name] = skill_instance
        logger.info(f"Registered skill: {skill_instance.name}")
        return skill_cls

    @classmethod
    def get_skill(cls, name: str) -> BaseSkill:
        return cls._skills.get(name)

    @classmethod
    def get_all_skills(cls) -> List[BaseSkill]:
        return list(cls._skills.values())

    @classmethod
    def get_skill_names(cls) -> List[str]:
        return [s.name for s in cls._skills.values()]
