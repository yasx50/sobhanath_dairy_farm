import os
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ConfigurationError
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

def get_mongo_connection():
    """
    Create and return a MongoDB connection
    """
    try:
        # Get connection string from environment variable
        connection_string = os.getenv("MONGO_CONNECTION_STRING")
        
        if not connection_string:
            raise ValueError("MONGO_CONNECTION_STRING not found in environment variables")
        
        # Create MongoDB client
        client = MongoClient(connection_string, serverSelectionTimeoutMS=5000)
        
        # Test the connection
        client.admin.command('ping')
        print("Successfully connected to MongoDB!")
        
        return client["goDairySmart"]
    
    except ConfigurationError as e:
        print(f"Configuration error: {e}")
        return None
    except ConnectionFailure as e:
        print(f"Connection failed: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None

# Usage example
# if __name__ == "__main__":
#     mongo_client = get_mongo_connection()
    
#     if mongo_client:
#         # Get database and collection
#         db = mongo_client["goDairySmart"]
#         collection = db["owners"]
        
#         # Example: Insert a document
#         # document = {"name": "John", "age": 30}
#         # result = collection.insert_one(document)
#         # print(f"Inserted document with ID: {result.inserted_id}")
        
#         # # Example: Find documents
#         # for doc in collection.find():
#         #     print(doc)
        
#         # Close the connection when done
#         # mongo_client.close()