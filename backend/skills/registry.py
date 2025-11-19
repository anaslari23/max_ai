from typing import Dict, Type, List
from backend.skills.base import BaseSkill
from backend.utils.logger import logger
class SkillRegistry:
    _skills: Dict[str, BaseSkill] = {}

    @classmethod
    def register(cls, skill_instance: BaseSkill):
        cls._skills[skill_instance.name] = skill_instance
        logger.info(f"Registered skill: {skill_instance.name}")
        return skill_instance

    @classmethod
    def register_defaults(cls):
        # Import here to avoid circular imports
        from backend.skills.media import MediaSkill
        from backend.skills.system import SystemSkill
        from backend.skills.learn import LearnSkill
        from backend.skills.phone import PhoneSkill
        from backend.skills.sms import SMSSkill
        from backend.skills.navigation import NavigationSkill
        from backend.skills.calendar import CalendarSkill
        from backend.skills.search import SearchSkill
        from backend.skills.weather import WeatherSkill
        from backend.skills.timer import TimerSkill
        from backend.skills.ingest import IngestSkill

        cls.register(PhoneSkill())
        cls.register(SMSSkill())
        cls.register(NavigationSkill())
        cls.register(CalendarSkill())
        cls.register(SearchSkill())
        cls.register(MediaSkill())
        cls.register(SystemSkill())
        cls.register(LearnSkill())
        cls.register(WeatherSkill())
        cls.register(TimerSkill())
        cls.register(IngestSkill())

    @classmethod
    def get_skill(cls, name: str) -> BaseSkill:
        return cls._skills.get(name)

    @classmethod
    def get_all_skills(cls) -> List[BaseSkill]:
        return list(cls._skills.values())

    @classmethod
    def get_skill_names(cls) -> List[str]:
        return [s.name for s in cls._skills.values()]
