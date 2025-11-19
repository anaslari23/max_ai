import re
from typing import Optional

def validate_email(email: str) -> bool:
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return bool(re.match(pattern, email))

def validate_phone_number(phone: str) -> bool:
    # Basic validation, can be improved
    return bool(re.match(r"^\+?1?\d{9,15}$", phone))

def sanitize_input(text: str) -> str:
    # Remove potentially dangerous characters if needed, 
    # mostly for display, but LLMs handle raw text usually.
    return text.strip()
