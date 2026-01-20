import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def test_api():
    print("Testing Backend API...")
    
    # 1. Create Dairy
    owner_id = "test_owner_123"
    print(f"\n1. Creating Dairy for Owner: {owner_id}")
    
    payload = {
        "owner_id": owner_id,
        "name": "Test Dairy Farm",
        "address": "123 Milky Way"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/dairy/create", json=payload)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("PASS: Dairy Created")
        else:
            print("FAIL: Create Dairy")
            
    except Exception as e:
        print(f"Error: {e}")
        
    # 2. Get Dairy
    print(f"\n2. Getting Dairy for Owner: {owner_id}")
    try:
        response = requests.get(f"{BASE_URL}/dairy/{owner_id}")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        data = response.json()
        if response.status_code == 200 and isinstance(data, list) and len(data) > 0:
             print("PASS: Got Dairy List")
        else:
             print("FAIL: Get Dairy")
             
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api()
