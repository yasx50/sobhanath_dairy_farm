from fastapi import APIRouter, HTTPException, Depends
from models.Dairy import Dairy
from models.OwnerSchema import Owner
from config.databseConnection import get_mongo_connection
from datetime import datetime

router = APIRouter(prefix="/dairy", tags=["Dairy"])

def get_db():
    return get_mongo_connection()

@router.post("/create")
def create_dairy(dairy: Dairy, db=Depends(get_db)):
    """
    Create a new dairy for an owner.
    """
    owners_collection = db["owners"]
    dairy_collection = db["dairies"]
    
    # Verify owner exists
    owner = owners_collection.find_one({"owner_id": dairy.owner_id})
    if not owner:
        raise HTTPException(status_code=404, detail="Owner not found")
        
    # Check if Owner already has a dairy (optional rule, but good for now)
    # For now, let's allow multiple or just one. Let's assume one for simplicity initially.
    
    # Ensure unique dairy_id
    while dairy_collection.find_one({"dairy_id": dairy.dairy_id}):
        dairy.dairy_id = dairy.generate_dairy_id() # Regenerate if collision
        
    dairy_data = dairy.model_dump(by_alias=True)
    dairy_collection.insert_one(dairy_data)
    
    # Update owner with dairy_id
    owners_collection.update_one(
        {"owner_id": dairy.owner_id},
        {"$push": {"dairies": dairy.dairy_id}}
    )
    
    return {"message": "Dairy created successfully", "dairy_id": dairy.dairy_id, "id": dairy.id}

@router.get("/{owner_id}")
def get_dairy_by_owner(owner_id: str, db=Depends(get_db)):
    """
    Get all dairies owned by a specific owner.
    """
    dairy_collection = db["dairies"]
    dairies = list(dairy_collection.find({"owner_id": owner_id}))
    
    if not dairies:
        return []
        
    # Convert ObjectId to str if needed or handle by Pydantic response model usually
    # But here we are returning raw dicts, need to ensure serialization
    for d in dairies:
        # d["_id"] = str(d["_id"]) 
        pass
        
    return dairies
