import Foundation

/**
 * BenchmarkManager - Performance Testing Orchestrator
 * 
 * This class orchestrates comprehensive performance testing between Core Data, SQLite, and Realm
 * implementations. It provides standardized benchmarking methodology with statistical
 * analysis to ensure fair and accurate performance comparisons.
 * 
 * Key Responsibilities:
 * - Execute identical operations on all persistence systems
 * - Measure execution times with high precision
 * - Perform statistical analysis (averaging, comparison)
 * - Generate standardized benchmark results
 * - Provide detailed performance insights
 * 
 * Benchmarking Methodology:
 * - Multiple repetitions for statistical accuracy
 * - High-precision timing using CFAbsoluteTimeGetCurrent()
 * - Controlled test data generation
 * - Isolated test environments
 * - Comprehensive operation coverage (CRUD + Updates)
 * 
 * Performance Metrics:
 * - Execution time in seconds (4 decimal precision)
 * - Average performance across multiple runs
 * - Direct comparison between Core Data, SQLite, and Realm
 * - Performance winner identification
 */
final class BenchmarkManager {

    // MARK: - Configuration Properties
    
    /// Core Data implementation for performance testing
    private let coreDataManager: DatabaseManager
    
    /// SQLite implementation for performance testing
    private let sqliteManager: DatabaseManager
    
    /// Realm implementation for performance testing
    private let realmManager: DatabaseManager
    
    /// SwiftData implementation for performance testing
    private let swiftDataManager: DatabaseManager
    
    /// Number of repetitions for statistical accuracy (default: 10)
    private let repetitions: Int
    
    /// Number of test records to process (default: 1,000)
    private let records: Int

    /**
     * Initialize benchmark manager with configurable parameters
     * 
     * This initializer allows customization of the benchmarking process through
     * dependency injection and configuration parameters. Default values are chosen
     * to provide reliable results while maintaining reasonable execution time.
     * 
     * Configuration Parameters:
     * - coreDataManager: Core Data implementation (default: CoreDataManager)
     * - sqliteManager: SQLite implementation (default: SQLiteManager)
     * - realmManager: Realm implementation (default: RealmManager)
     * - repetitions: Number of test repetitions (default: 10)
     * - records: Number of test records (default: 1,000)
     * 
     * Design Decisions:
     * - 10 repetitions: Balances statistical accuracy with execution time
     * - 1,000 records: Large enough for meaningful performance differences
     * - Dependency injection: Enables testing with mock implementations
     * 
     * @param coreDataManager Core Data implementation to test
     * @param sqliteManager SQLite implementation to test
     * @param realmManager Realm implementation to test
     * @param repetitions Number of repetitions for statistical accuracy
     * @param records Number of test records to process
     */
    init(coreDataManager: DatabaseManager = CoreDataManager(),
         sqliteManager: DatabaseManager = SQLiteManager(),
         realmManager: DatabaseManager = RealmManager(),
         swiftDataManager: DatabaseManager = SwiftDataManager(),
         repetitions: Int = 10,
         records: Int = 1_000) {
        self.coreDataManager = coreDataManager
        self.sqliteManager = sqliteManager
        self.realmManager = realmManager
        self.swiftDataManager = swiftDataManager
        self.repetitions = repetitions
        self.records = records
    }

    /**
     * Execute insert operation benchmarks comparing single vs bulk performance
     * 
     * This method performs comprehensive insert operation testing to compare
     * the performance characteristics of individual vs bulk insert operations
     * between Core Data, SQLite, and Realm implementations.
     * 
     * Test Operations:
     * - Insert Single: Individual record insertion with separate transactions
     * - Insert Bulk: Batch insertion within single transaction
     * 
     * Performance Insights:
     * - Single inserts: Tests transaction overhead and individual operation cost
     * - Bulk inserts: Tests batch processing efficiency and transaction benefits
     * - Core Data vs SQLite vs Realm: Object graph overhead vs direct database access vs object-oriented database
     * 
     * Expected Results:
     * - Bulk operations should be significantly faster than single operations
     * - SQLite typically fastest for single inserts (lowest overhead)
     * - Realm may be competitive for bulk operations (optimized object management)
     * - Core Data may excel in complex object graph scenarios
     * 
     * @return Array of BenchmarkResult objects with performance metrics
     */
    func runSingleVsBulk() -> [BenchmarkResult] {
        let testData = generateTestData(count: records)

        // Core Data Performance Testing
        let coreSingle = repeatMeasure(repetitions) { coreDataManager.insertSingle(data: testData) }
        let coreBulk   = repeatMeasure(repetitions) { coreDataManager.insertBulk(data: testData) }

        // SQLite Performance Testing
        let sqliteSingle = repeatMeasure(repetitions) { sqliteManager.insertSingle(data: testData) }
        let sqliteBulk   = repeatMeasure(repetitions) { sqliteManager.insertBulk(data: testData) }

        // Realm Performance Testing
        let realmSingle = repeatMeasure(repetitions) { realmManager.insertSingle(data: testData) }
        let realmBulk   = repeatMeasure(repetitions) { realmManager.insertBulk(data: testData) }

        // SwiftData Performance Testing
        let swiftDataSingle = repeatMeasure(repetitions) { swiftDataManager.insertSingle(data: testData) }
        let swiftDataBulk   = repeatMeasure(repetitions) { swiftDataManager.insertBulk(data: testData) }

        // Create benchmark results with statistical analysis
        let results: [BenchmarkResult] = [
            BenchmarkResult(operation: "Insert Single", coreDataAverage: coreSingle.average, sqliteAverage: sqliteSingle.average, realmAverage: realmSingle.average, swiftDataAverage: swiftDataSingle.average),
            BenchmarkResult(operation: "Insert Bulk",   coreDataAverage: coreBulk.average,   sqliteAverage: sqliteBulk.average, realmAverage: realmBulk.average, swiftDataAverage: swiftDataBulk.average)
        ]

        // Console output for real-time monitoring
        for r in results {
            print("Operation: \(r.operation)")
            print("  Core Data Avg: \(String(format: "%.4fs", r.coreDataAverage))")
            print("  SQLite Avg: \(String(format: "%.4fs", r.sqliteAverage))")
            print("  Realm Avg: \(String(format: "%.4fs", r.realmAverage))")
            print("  SwiftData Avg: \(String(format: "%.4fs", r.swiftDataAverage))")
            print("  Faster Method: \(r.fasterMethod)\n")
        }

        return results
    }
    
    /**
     * Execute comprehensive update operation benchmarks
     * 
     * This method performs extensive update operation testing to compare
     * various update strategies and their performance characteristics
     * between Core Data, SQLite, and Realm implementations.
     * 
     * Test Operations:
     * - Update Single: Individual record update by ID
     * - Update Bulk: Update all records with same values
     * - Update Conditional: Update records within age range
     * - Update Incremental: Mathematical operations on existing values
     * - Update Multiple: Update specific records by ID list
     * 
     * Performance Insights:
     * - Single updates: Tests individual record modification overhead
     * - Bulk updates: Tests mass data modification efficiency
     * - Conditional updates: Tests query + update performance
     * - Incremental updates: Tests mathematical operation efficiency
     * - Multiple updates: Tests targeted batch operations
     * 
     * Expected Results:
     * - SQLite typically fastest for direct operations
     * - Realm may excel in object-oriented scenarios
     * - Core Data may excel in complex object graph scenarios
     * - Bulk operations should outperform individual operations
     * - Mathematical operations may favor SQLite's direct SQL
     * 
     * @return Array of BenchmarkResult objects with performance metrics
     */
    func runUpdateBenchmarks() -> [BenchmarkResult] {
        let testData = generateTestData(count: records)
        
        // Prepare test data in all systems
        coreDataManager.insertBulk(data: testData)
        sqliteManager.insertBulk(data: testData)
        realmManager.insertBulk(data: testData)
        swiftDataManager.insertBulk(data: testData)
        
        var results: [BenchmarkResult] = []
        
        // Single Update by ID - Tests individual record modification
        let coreSingleUpdate = repeatMeasure(repetitions) { 
            coreDataManager.updateSingleById(id: 1, newName: "Updated", newAge: 25) 
        }
        let sqliteSingleUpdate = repeatMeasure(repetitions) { 
            sqliteManager.updateSingleById(id: 1, newName: "Updated", newAge: 25) 
        }
        let realmSingleUpdate = repeatMeasure(repetitions) { 
            realmManager.updateSingleById(id: 1, newName: "Updated", newAge: 25) 
        }
        let swiftDataSingleUpdate = repeatMeasure(repetitions) { 
            swiftDataManager.updateSingleById(id: 1, newName: "Updated", newAge: 25) 
        }
        
        // Bulk Update All Records - Tests mass data modification
        let coreBulkUpdate = repeatMeasure(repetitions) { 
            coreDataManager.updateAllRecords(newName: "Bulk Updated", newAge: 30) 
        }
        let sqliteBulkUpdate = repeatMeasure(repetitions) { 
            sqliteManager.updateAllRecords(newName: "Bulk Updated", newAge: 30) 
        }
        let realmBulkUpdate = repeatMeasure(repetitions) { 
            realmManager.updateAllRecords(newName: "Bulk Updated", newAge: 30) 
        }
        let swiftDataBulkUpdate = repeatMeasure(repetitions) { 
            swiftDataManager.updateAllRecords(newName: "Bulk Updated", newAge: 30) 
        }
        
        // Conditional Update by Age Range - Tests query + update performance
        let coreConditionalUpdate = repeatMeasure(repetitions) { 
            coreDataManager.updateByAgeRange(minAge: 20, maxAge: 40, newName: "Range Updated", newAge: 35) 
        }
        let sqliteConditionalUpdate = repeatMeasure(repetitions) { 
            sqliteManager.updateByAgeRange(minAge: 20, maxAge: 40, newName: "Range Updated", newAge: 35) 
        }
        let realmConditionalUpdate = repeatMeasure(repetitions) { 
            realmManager.updateByAgeRange(minAge: 20, maxAge: 40, newName: "Range Updated", newAge: 35) 
        }
        let swiftDataConditionalUpdate = repeatMeasure(repetitions) { 
            swiftDataManager.updateByAgeRange(minAge: 20, maxAge: 40, newName: "Range Updated", newAge: 35) 
        }
        
        // Incremental Update - Tests mathematical operations
        let coreIncrementalUpdate = repeatMeasure(repetitions) { 
            coreDataManager.incrementAgeBy(amount: 1) 
        }
        let sqliteIncrementalUpdate = repeatMeasure(repetitions) { 
            sqliteManager.incrementAgeBy(amount: 1) 
        }
        let realmIncrementalUpdate = repeatMeasure(repetitions) { 
            realmManager.incrementAgeBy(amount: 1) 
        }
        let swiftDataIncrementalUpdate = repeatMeasure(repetitions) { 
            swiftDataManager.incrementAgeBy(amount: 1) 
        }
        
        // Multiple IDs Update - Tests targeted batch operations
        let testIds = Array(1...100).map { Int64($0) }
        let coreMultipleUpdate = repeatMeasure(repetitions) { 
            coreDataManager.updateMultipleByIds(ids: testIds, newName: "Multiple Updated", newAge: 28) 
        }
        let sqliteMultipleUpdate = repeatMeasure(repetitions) { 
            sqliteManager.updateMultipleByIds(ids: testIds, newName: "Multiple Updated", newAge: 28) 
        }
        let realmMultipleUpdate = repeatMeasure(repetitions) { 
            realmManager.updateMultipleByIds(ids: testIds, newName: "Multiple Updated", newAge: 28) 
        }
        let swiftDataMultipleUpdate = repeatMeasure(repetitions) { 
            swiftDataManager.updateMultipleByIds(ids: testIds, newName: "Multiple Updated", newAge: 28) 
        }
        
        // Compile results with statistical analysis
        results.append(BenchmarkResult(operation: "Update Single", coreDataAverage: coreSingleUpdate.average, sqliteAverage: sqliteSingleUpdate.average, realmAverage: realmSingleUpdate.average, swiftDataAverage: swiftDataSingleUpdate.average))
        results.append(BenchmarkResult(operation: "Update Bulk", coreDataAverage: coreBulkUpdate.average, sqliteAverage: sqliteBulkUpdate.average, realmAverage: realmBulkUpdate.average, swiftDataAverage: swiftDataBulkUpdate.average))
        results.append(BenchmarkResult(operation: "Update Conditional", coreDataAverage: coreConditionalUpdate.average, sqliteAverage: sqliteConditionalUpdate.average, realmAverage: realmConditionalUpdate.average, swiftDataAverage: swiftDataConditionalUpdate.average))
        results.append(BenchmarkResult(operation: "Update Incremental", coreDataAverage: coreIncrementalUpdate.average, sqliteAverage: sqliteIncrementalUpdate.average, realmAverage: realmIncrementalUpdate.average, swiftDataAverage: swiftDataIncrementalUpdate.average))
        results.append(BenchmarkResult(operation: "Update Multiple", coreDataAverage: coreMultipleUpdate.average, sqliteAverage: sqliteMultipleUpdate.average, realmAverage: realmMultipleUpdate.average, swiftDataAverage: swiftDataMultipleUpdate.average))
        
        // Console output for real-time monitoring
        for r in results {
            print("Operation: \(r.operation)")
            print("  Core Data Avg: \(String(format: "%.4fs", r.coreDataAverage))")
            print("  SQLite Avg: \(String(format: "%.4fs", r.sqliteAverage))")
            print("  Realm Avg: \(String(format: "%.4fs", r.realmAverage))")
            print("  SwiftData Avg: \(String(format: "%.4fs", r.swiftDataAverage))")
            print("  Faster Method: \(r.fasterMethod)\n")
        }
        
        return results
    }
    
    /**
     * Execute comprehensive benchmark suite covering all operations
     * 
     * This method orchestrates the complete benchmark testing suite,
     * combining both insert and update operation benchmarks to provide
     * a comprehensive performance analysis of all persistence systems.
     * 
     * Benchmark Coverage:
     * - Insert operations (single vs bulk)
     * - Update operations (various strategies)
     * - Complete performance profile
     * - Statistical analysis across all operations
     * 
     * Use Cases:
     * - Full system performance evaluation
     * - Comprehensive comparison reports
     * - Complete benchmark execution
     * - Performance regression testing
     * 
     * @return Complete array of BenchmarkResult objects for all operations
     */
    func runAllBenchmarks() -> [BenchmarkResult] {
        var allResults: [BenchmarkResult] = []
        
        // Execute insert operation benchmarks
        allResults.append(contentsOf: runSingleVsBulk())
        
        // Execute update operation benchmarks
        allResults.append(contentsOf: runUpdateBenchmarks())
        
        return allResults
    }

    // MARK: - Helper Methods

    /**
     * Generate standardized test data for benchmarking
     * 
     * This method creates consistent test data that ensures fair comparison
     * between Core Data, SQLite, and Realm implementations. The data is designed
     * to be realistic while maintaining predictable characteristics.
     * 
     * Data Characteristics:
     * - Sequential IDs starting from 0
     * - Predictable naming pattern ("Person 0", "Person 1", etc.)
     * - Random ages between 18-65 (realistic range)
     * - Consistent data structure across all records
     * 
     * Design Decisions:
     * - Sequential IDs: Enable predictable targeting for update tests
     * - Random ages: Provide realistic data distribution for range queries
     * - Predictable names: Enable pattern matching tests
     * - Large dataset: Ensure meaningful performance differences
     * 
     * @param count Number of test records to generate
     * @return Array of Person objects with standardized test data
     */
    private func generateTestData(count: Int) -> [Person] {
        return (0..<count).map { Person(id: $0, name: "Person \($0)", age: Int.random(in: 18...65)) }
    }

    /**
     * Execute performance measurement with statistical repetition
     * 
     * This method implements the core benchmarking logic by executing
     * a given operation multiple times and measuring execution times
     * with high precision. It provides statistical accuracy through
     * multiple repetitions and uses the most precise timing available.
     * 
     * Timing Methodology:
     * - CFAbsoluteTimeGetCurrent() for maximum precision
     * - Wall-clock time measurement (includes all overhead)
     * - Multiple repetitions for statistical accuracy
     * - Individual timing for each repetition
     * 
     * Statistical Benefits:
     * - Reduces impact of system variations
     * - Provides average performance metrics
     * - Identifies performance consistency
     * - Enables reliable performance comparisons
     * 
     * @param times Number of repetitions for statistical accuracy
     * @param block Operation to measure (closure)
     * @return Array of execution times in seconds
     */
    private func repeatMeasure(_ times: Int, block: () -> Void) -> [Double] {
        var results: [Double] = []
        for _ in 0..<times {
            let start = CFAbsoluteTimeGetCurrent()
            block()
            let end = CFAbsoluteTimeGetCurrent()
            results.append(end - start)
        }
        return results
    }
}

// MARK: - Statistical Analysis Extensions

/**
 * Array extension for statistical analysis of timing data
 * 
 * This extension provides statistical analysis capabilities for arrays
 * of timing measurements, enabling calculation of average performance
 * metrics from multiple benchmark repetitions.
 * 
 * Statistical Methods:
 * - Average calculation for performance metrics
 * - Foundation for more complex statistical analysis
 * - Enables performance comparison between implementations
 */
extension Array where Element == Double {
    /**
     * Calculate average execution time from timing measurements
     * 
     * This computed property calculates the arithmetic mean of all
     * timing measurements in the array, providing a representative
     * performance metric that accounts for system variations.
     * 
     * Statistical Benefits:
     * - Reduces impact of outliers and system variations
     * - Provides representative performance metric
     * - Enables fair comparison between implementations
     * - Foundation for performance analysis
     * 
     * @return Average execution time in seconds
     */
    var average: Double { self.reduce(0, +) / Double(self.count) }
}

// MARK: - Performance Analysis Documentation

/**
 * BenchmarkManager Performance Analysis Framework
 * 
 * This class provides a comprehensive framework for analyzing and comparing
 * the performance characteristics of different persistence implementations.
 * The framework is designed to provide reliable, statistically sound
 * performance measurements that enable informed technology decisions.
 * 
 * Key Features:
 * - Statistical accuracy through multiple repetitions
 * - High-precision timing measurements
 * - Comprehensive operation coverage
 * - Standardized comparison methodology
 * - Real-time performance monitoring
 * 
 * Use Cases:
 * - Technology selection for persistence layer
 * - Performance optimization analysis
 * - Regression testing for performance changes
 * - Educational demonstration of performance characteristics
 * - Research and development of persistence strategies
 */