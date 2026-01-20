from google.oauth2 import id_token
from google.auth.transport import requests
from fastapi import HTTPException
from dotenv import load_dotenv
load_dotenv()
import os

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")

def verify_google_token(token: str):
    try:
        idinfo = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            GOOGLE_CLIENT_ID
        )

        return {
            "email": idinfo["email"],
            "name": idinfo["name"],
            "picture": idinfo.get("picture"),
            "provider": "GOOGLE"
        }

    except Exception:
        raise HTTPException(status_code=401, detail="Invalid Google token")
