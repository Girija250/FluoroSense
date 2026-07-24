import requests
import time
import concurrent.futures
import random
from report_generator import generate_excel_report

BASE_URL = "http://localhost:8000"
NUM_REQUESTS = 300 # Scaled up to 300 test cases
MAX_WORKERS = 20

ENDPOINTS_TO_TEST = [
    {"path": "/", "method": "GET"},
    {"path": "/register", "method": "POST", "payload": {"email": "loadtest@example.com", "password": "loadpassword"}},
    {"path": "/token", "method": "POST", "data": {"username": "loadtest@example.com", "password": "loadpassword"}},
    {"path": "/users/me", "method": "GET", "headers": {"Authorization": "Bearer fake_token"}}
]

def make_request(request_id):
    start_time = time.time()
    # Randomly select an endpoint to simulate mixed traffic load
    target = random.choice(ENDPOINTS_TO_TEST)
    
    try:
        if target["method"] == "GET":
            response = requests.get(f"{BASE_URL}{target['path']}", headers=target.get("headers", {}))
        else:
            if "data" in target:
                response = requests.post(f"{BASE_URL}{target['path']}", data=target["data"], headers=target.get("headers", {}))
            else:
                response = requests.post(f"{BASE_URL}{target['path']}", json=target.get("payload", {}), headers=target.get("headers", {}))
                
        end_time = time.time()
        latency = end_time - start_time
        
        # We consider any response from the server (even 4xx/5xx) as a successful load test cycle 
        # (meaning the server didn't crash and responded in time). 
        # Latency is the main metric here.
        return {
            "Request_ID": request_id,
            "Endpoint": target["path"],
            "Method": target["method"],
            "Status_Code": response.status_code,
            "Latency_Seconds": round(latency, 4),
            "Result": "PASS" if latency < 2.0 else "WARNING" # Flag if taking more than 2 seconds
        }
    except Exception as e:
        return {
            "Request_ID": request_id,
            "Endpoint": target["path"],
            "Method": target["method"],
            "Status_Code": "ERROR",
            "Latency_Seconds": round(time.time() - start_time, 4),
            "Result": "FAIL",
            "Error": str(e)[:50]
        }

def run_load_tests():
    print(f"Starting Comprehensive Load Test Suite: {NUM_REQUESTS} mixed requests with {MAX_WORKERS} concurrent workers...")
    results = []
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = [executor.submit(make_request, i) for i in range(1, NUM_REQUESTS + 1)]
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())
            
    # Sort by ID
    results = sorted(results, key=lambda x: x["Request_ID"])
    
    # Calculate aggregates
    total_time = sum(r["Latency_Seconds"] for r in results)
    avg_latency = total_time / len(results) if results else 0
    print(f"Load Test Complete. Average Latency: {avg_latency:.4f} seconds")
    
    # Generate Report
    generate_excel_report(results, "load_report.xlsx")

if __name__ == "__main__":
    run_load_tests()
