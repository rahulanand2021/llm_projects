import subprocess


def write_output(cpp):
    code = cpp.replace("```cpp","").replace("```","")
    with open("optimized.cpp", "w") as f:
        f.write(code)

def execute_cpp():
        # write_output(code)
        try:
            compile_cmd = ["g++", "-Ofast", "-std=c++17", "-march=native", "-o", "testcp.exe", "testcp.cpp"]
            compile_result = subprocess.run(compile_cmd, check=True, text=True, capture_output=True)
            run_cmd = ["./testcp.exe"]
            run_result = subprocess.run(run_cmd, check=True, text=True, capture_output=True)
            return run_result.stdout
        except subprocess.CalledProcessError as e:
            return f"An error occurred:\n{e.stderr}"

print(execute_cpp())