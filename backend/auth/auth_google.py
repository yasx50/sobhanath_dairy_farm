from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime
from config.googleAuth import verify_google_token

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

# ---------------- REQUEST BODY ----------------
class GoogleAuthRequest(BaseModel):
    token: str

# ---------------- ROUTE ----------------
@router.post("/google")
def google_login(data: GoogleAuthRequest, owners):
    user = verify_google_token(data.token)

    existing_owner = owners.find_one({"email": user["email"]})

    if not existing_owner:
        new_owner = {
            "email": user["email"],
            "name": user["name"],
            "picture": user["picture"],
            "auth_provider": "GOOGLE",
            "role": "OWNER",
            "is_active": True,
            "plan": "FREE",
            "max_customers_allowed": 10,
            "created_at": datetime.utcnow(),
            "last_login": datetime.utcnow()
        }
        owners.insert_one(new_owner)

        return {
            "message": "Owner registered successfully",
            "user": new_owner
        }

    owners.update_one(
        {"email": user["email"]},
        {"$set": {"last_login": datetime.utcnow()}}
    )

    return {
        "message": "Login successful",
        "user": existing_owner
    }
