from jose import jwt
from datetime import datetime, timedelta

SECRET_KEY = "SUPER_SECRET"
ALGORITHM = "HS256"

def create_jwt(user_id: str):
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(days=7)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
