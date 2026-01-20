from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
import uuid
import random
import string

def generate_dairy_id():
    """Generate a random 6-character alphanumeric ID"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

class Dairy(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex, alias="_id")
    owner_id: str
    dairy_id: str = Field(default_factory=generate_dairy_id)
    name: str
    address: str
    
    customers: List[str] = [] # List of Customer IDs
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        populate_by_name = True
