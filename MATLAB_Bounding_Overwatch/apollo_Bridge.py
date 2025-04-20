import pandas as pd
import subprocess
import os
import json  # Add this import

def estimate_parameters(csv_path, r_script_path="DFT_Resource_Allocation.R", output_dir="output"):
    """
    Run Apollo estimation on a dataset and return phi1, phi2, tau, and error_sd
    :param csv_path: Path to the user_choices CSV file (already saved by MATLAB)
    """
    # Run the R script to estimate parameters
    try:
        result = subprocess.run(["Rscript", r_script_path], capture_output=True, check=True)
        print("R script output:\n", result.stdout.decode())
    except subprocess.CalledProcessError as e:
        print("Error during R execution:\n", e.stderr.decode())
        return None

    # Expected Apollo output
    result_file = os.path.join(output_dir, "DFT_Resource_Allocation_model.csv")
    
    if not os.path.exists(result_file):
        raise FileNotFoundError("Apollo model output not found.")

    # Read the Apollo output CSV
    model_df = pd.read_csv(result_file)

    # Extract the desired parameter estimates
    param_names = ["phi1", "phi2", "timesteps", "error_sd"]
    params = {}
    for name in param_names:
        row = model_df[model_df["Name"] == name]
        if not row.empty:
            params[name] = float(row["Estimate"].values[0])
        else:
            raise KeyError(f"Parameter {name} not found in Apollo output.")

    # At the end of the function, BEFORE return:
    print(json.dumps(params))  # Add this line
    return params  # Dictionary: {'phi1': ..., 'phi2': ..., 'timesteps': ..., 'error_sd': ...}
