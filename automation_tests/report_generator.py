import os
import pandas as pd

def generate_excel_report(data_list, filename):
    """
    Takes a list of dictionaries and saves them as an Excel report.
    Args:
        data_list (list): List of dictionaries containing test results.
        filename (str): Name of the output excel file (e.g., 'report.xlsx').
    """
    # Ensure reports directory exists
    reports_dir = os.path.join(os.path.dirname(__file__), "..", "reports")
    os.makedirs(reports_dir, exist_ok=True)
    
    filepath = os.path.join(reports_dir, filename)
    
    # Create DataFrame and save
    df = pd.DataFrame(data_list)
    df.to_excel(filepath, index=False)
    print(f"Report successfully saved to {filepath}")
