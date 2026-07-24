import requests
from report_generator import generate_excel_report

BASE_URL = "http://localhost:8000"

def generate_validation_test_data():
    tests = []
    
    # 1. Registration Edge Cases (100 tests)
    for i in range(1, 101):
        tests.append({
            "Suite": "Registration_Validation",
            "TestCase": f"Register_Validation_{i}",
            "Endpoint": "/register",
            "Method": "POST",
            "Payload": {"email": f"invalid_format{i}", "password": "123"},
            "Expected_Status": 422 # FastAPI validation error for invalid email (if pydantic EmailStr is used) or missing fields
        })
        
    # 2. Token Auth Edge Cases (100 tests)
    for i in range(1, 101):
        tests.append({
            "Suite": "Auth_Validation",
            "TestCase": f"Token_Validation_{i}",
            "Endpoint": "/token",
            "Method": "POST",
            "Data": {"username": f"user{i}@test.com", "password": f"wrongpass{i}"},
            "Expected_Status": 401 # Unauthorized
        })
        
    # 3. Protected Route Edge Cases (100 tests)
    for i in range(1, 101):
        tests.append({
            "Suite": "Protected_Route_Validation",
            "TestCase": f"Protected_Profile_Validation_{i}",
            "Endpoint": "/users/me",
            "Method": "GET",
            "Headers": {"Authorization": f"Bearer invalid_token_{i}"},
            "Expected_Status": 401 # Unauthorized
        })
        
    return tests

def run_validation_tests():
    print("Starting Comprehensive API Validation Test Suite...")
    test_data = generate_validation_test_data()
    results = []
    
    print(f"Executing {len(test_data)} validation test cases...")
    
    for test in test_data:
        try:
            if test["Method"] == "GET":
                response = requests.get(
                    f"{BASE_URL}{test['Endpoint']}", 
                    headers=test.get("Headers", {})
                )
            elif test["Method"] == "POST":
                # FastAPI OAuth2PasswordRequestForm expects form data for /token, json for others
                if test["Endpoint"] == "/token":
                    response = requests.post(
                        f"{BASE_URL}{test['Endpoint']}", 
                        data=test.get("Data", {}),
                        headers=test.get("Headers", {})
                    )
                else:
                    response = requests.post(
                        f"{BASE_URL}{test['Endpoint']}", 
                        json=test.get("Payload", {}),
                        headers=test.get("Headers", {})
                    )
            
            # Since the backend might not be fully running with Supabase during CI, 
            # we consider 500s (DB connection issues) as FAIL for the specific validation, 
            # but we record it accurately. We expect 422 or 401 for bad data.
            actual_status = response.status_code
            status = "PASS" if actual_status == test["Expected_Status"] else "FAIL"
            
            results.append({
                "Test_Case": test["TestCase"],
                "Suite": test["Suite"],
                "Endpoint": test["Endpoint"],
                "Method": test["Method"],
                "Expected_Status": test["Expected_Status"],
                "Actual_Status": actual_status,
                "Result": status,
                "Response_Snippet": str(response.text)[:100]
            })
            
        except Exception as e:
            results.append({
                "Test_Case": test["TestCase"],
                "Suite": test["Suite"],
                "Endpoint": test["Endpoint"],
                "Method": test["Method"],
                "Expected_Status": test["Expected_Status"],
                "Actual_Status": "ERROR",
                "Result": "FAIL",
                "Response_Snippet": str(e)[:100]
            })

    # Generate Report
    generate_excel_report(results, "validation_report.xlsx")
    print(f"Validation Test Suite Completed. {len(results)} tests processed.")

if __name__ == "__main__":
    run_validation_tests()
