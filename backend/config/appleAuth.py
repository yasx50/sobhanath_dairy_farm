import jwt
import requests

APPLE_AUDIENCE = "com.your.app.bundleid"

def verify_apple_token(identity_token: str):
    apple_keys = requests.get(
        "https://appleid.apple.com/auth/keys"
    ).json()

    header = jwt.get_unverified_header(identity_token)

    key = next(
        k for k in apple_keys["keys"]
        if k["kid"] == header["kid"]
    )

    payload = jwt.decode(
        identity_token,
        key,
        audience=APPLE_AUDIENCE,
        algorithms=["RS256"]
    )

    return {
        "email": payload.get("email"),
        "provider": "APPLE"
    }
