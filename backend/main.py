from fastapi import FastAPI, Depends
from config.databseConnection import get_mongo_connection
from auth.auth_google import router as google_auth_router
from routers import dairy


app = FastAPI(title="GoDairySmart API")

# ---------------- DB DEPENDENCY ----------------
def get_owners_collection():
    db = get_mongo_connection()
    return db["owners"]

# ---------------- ROUTERS ----------------
app.include_router(
    google_auth_router,
    dependencies=[Depends(get_owners_collection)]
)
app.include_router(dairy.router)


# ---------------- ENTRY POINT ----------------
def main():
    get_mongo_connection()  # DB init (optional but fine)

if __name__ == "__main__":
    main()
