/**
 * BenchmarkResult - Performance Comparison Model
 * 
 * This struct represents the results of a performance benchmark comparison
 * between Core Data, SQLite, and Realm implementations. It provides
 * statistical analysis and performance winner identification.
 * 
 * Performance Metrics:
 * - Average execution time for each implementation
 * - Performance winner identification
 * - Statistical comparison capabilities
 * - Standardized result format
 * 
 * Use Cases:
 * - Performance comparison reporting
 * - Technology selection analysis
 * - Performance regression testing
 * - Educational demonstration
 */
struct BenchmarkResult {
    let operation: String
    let coreDataAverage: Double
    let sqliteAverage: Double
    let realmAverage: Double
    let swiftDataAverage: Double

    /**
     * Identify the fastest implementation based on average execution time
     * 
     * This computed property determines which persistence implementation
     * performed fastest for the given operation by comparing average
     * execution times across all three systems.
     * 
     * Comparison Logic:
     * - Compares all three average execution times
     * - Returns the implementation with the lowest time
     * - Handles ties by returning "Equal"
     * 
     * @return String identifying the fastest implementation
     */
    var fasterMethod: String {
        let times = [
            ("Core Data", coreDataAverage),
            ("SQLite", sqliteAverage),
            ("Realm", realmAverage),
            ("SwiftData", swiftDataAverage)
        ]
        
        let sortedTimes = times.sorted { $0.1 < $1.1 }
        let fastest = sortedTimes[0]
        let secondFastest = sortedTimes[1]
        
        // Check for ties
        if fastest.1 == secondFastest.1 {
            return "Tie: \(fastest.0) & \(secondFastest.0)"
        }
        
        return fastest.0
    }
    
    /**
     * Calculate performance improvement percentage of fastest over slowest
     * 
     * This computed property calculates the performance improvement percentage
     * of the fastest implementation compared to the slowest implementation,
     * providing insight into the magnitude of performance differences.
     * 
     * @return Performance improvement percentage
     */
    var performanceImprovement: Double {
        let times = [coreDataAverage, sqliteAverage, realmAverage, swiftDataAverage]
        let fastest = times.min() ?? 0
        let slowest = times.max() ?? 0
        
        if slowest == 0 { return 0 }
        return ((slowest - fastest) / slowest) * 100
    }
}
