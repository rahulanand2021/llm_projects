
#include <iostream>
#include <iomanip>
#include <chrono>

// Perform the calculation with given parameters
double calculate(int iterations, int param1, int param2) {
    double result = 1.0;
    for (int i = 1; i <= iterations; ++i) {
        int j = i * param1 - param2;
        result -= (1.0 / j);
        j = i * param1 + param2;
        result += (1.0 / j);
    }
    return result;
}

int main() {
    // Measure the execution time
    auto start_time = std::chrono::high_resolution_clock::now();
    
    // Perform the calculation and multiply the result by 4
    double result = calculate(100000000, 4, 1) * 4;
    
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end_time - start_time;
    
    // Print the results and timing information with the specified precision
    std::cout << "Result: " << std::fixed << std::setprecision(12) << result << std::endl;
    std::cout << "Execution Time: " << std::fixed << std::setprecision(6) << elapsed.count() << " seconds" << std::endl;

    return 0;
}
