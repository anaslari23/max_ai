from abc import ABC, abstractmethod
from typing import Dict, Any, Optional

class BaseSkill(ABC):
    name: str = "base_skill"
    description: str = "Base class for skills"
    
    @abstractmethod
    async def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the skill with provided parameters.
        """
        pass

    @property
    def definition(self) -> Dict[str, Any]:
        """
        Return the skill definition for the LLM.
        """
        return {
            "name": self.name,
            "description": self.description
        }
