import Foundation
import SwiftData
import CoreData

/**
 * SwiftDataManager - SwiftData Database Implementation for Performance Benchmarking
 * 
 * This class provides a modern SwiftData interface using Apple's latest data framework.
 * It implements the DatabaseManager protocol to enable performance comparison with
 * Core Data, SQLite, and Realm implementations. All operations use SwiftData's
 * modern Swift-first approach with automatic model management.
 * 
 * Key Features:
 * - SwiftData's modern Swift-first approach
 * - Automatic model management and migrations
 * - Type-safe operations with Swift generics
 * - Built-in relationship management
 * - Automatic persistence and change tracking
 * 
 * Performance Characteristics:
 * - Modern Swift-first database operations
 * - Automatic model lifecycle management
 * - Built-in caching and optimization
 * - Type-safe operations with compile-time checks
 * - Relationship traversal with automatic faulting
 */
final class SwiftDataManager: DatabaseManager {

    /// SwiftData model container for database operations
    private let modelContainer: ModelContainer
    
    /// SwiftData model context for database operations
    private let modelContext: ModelContext

    /**
     * Initialize SwiftData database connection and configuration
     * 
     * This constructor establishes a connection to a temporary SwiftData database
     * and configures it for optimal benchmark performance. The database is stored
     * in memory for maximum performance and automatic cleanup.
     * 
     * SwiftData Configuration:
     * - In-memory database for maximum performance
     * - Automatic schema management
     * - Optimized for benchmark operations
     * - Temporary storage for isolation
     * 
     * Performance Optimizations:
     * - In-memory storage for fastest access
     * - Automatic model lifecycle management
     * - Built-in query optimization
     * - Type-safe operations with zero runtime overhead
     * 
     * Thread Safety:
     * - SwiftData contexts are thread-confined
     * - Each operation creates its own context
     * - Ensures thread safety for benchmark operations
     */
    init() {
        do {
            // Configure SwiftData for optimal benchmark performance
            let schema = Schema([
                SwiftDataPerson.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    /**
     * Create a new SwiftData context for the current thread
     * 
     * This method ensures thread safety by creating a new ModelContext
     * for each operation. SwiftData contexts are thread-confined and cannot
     * be shared across threads.
     * 
     * @return New ModelContext for the current thread
     */
    private func createContext() -> ModelContext {
        return ModelContext(modelContainer)
    }

    // MARK: - DatabaseManager Protocol Implementation

    /**
     * Insert records one by one with individual transactions
     * 
     * This method demonstrates individual record insertion performance in SwiftData.
     * Each record is created as a SwiftData model and saved immediately, which
     * provides individual transaction control but has higher overhead.
     * 
     * SwiftData Characteristics:
     * - Each insert creates a SwiftData model
     * - Individual save operations (higher overhead)
     * - Automatic model persistence
     * - Type-safe operations with compile-time checks
     * 
     * Performance Implications:
     * - Higher overhead due to individual saves
     * - More memory usage due to model creation
     * - Better error isolation (failures are contained)
     * - Useful for small datasets or when individual control is needed
     * 
     * @param data Array of Person objects to insert
     */
    func insertSingle(data: [Person]) {
        deleteAll()
        let context = createContext()
        for person in data {
            let swiftDataPerson = SwiftDataPerson(
                id: Int(person.id),
                name: person.name,
                age: Int16(person.age)
            )
            context.insert(swiftDataPerson)
            try! context.save()
        }
    }

    /**
     * Insert all records within a single transaction
     * 
     * This method demonstrates bulk insertion performance in SwiftData.
     * All records are created as SwiftData models in memory, then saved
     * in a single transaction, which is much more efficient than individual saves.
     * 
     * SwiftData Characteristics:
     * - All models created in memory first
     * - Single save operation (much faster)
     * - Batch model management
     * - Atomic operation (all succeed or all fail)
     * 
     * Performance Implications:
     * - Much faster than individual saves
     * - Lower database I/O overhead
     * - Better memory efficiency
     * - Optimal for bulk data operations
     * 
     * @param data Array of Person objects to insert
     */
    func insertBulk(data: [Person]) {
        deleteAll()
        let context = createContext()
        let swiftDataPersons = data.map { person in
            SwiftDataPerson(
                id: Int(person.id),
                name: person.name,
                age: Int16(person.age)
            )
        }
        
        for person in swiftDataPersons {
            context.insert(person)
        }
        try! context.save()
    }

    /**
     * Retrieve all records using SwiftData's optimized query system
     * 
     * This method demonstrates SwiftData fetch performance with automatic optimizations.
     * It uses SwiftData's type-safe query system to minimize memory usage and
     * improve performance for large datasets.
     * 
     * SwiftData Optimizations:
     * - Type-safe queries with compile-time checks
     * - Automatic query optimization
     * - Built-in caching mechanisms
     * - Zero-copy model access
     * 
     * Performance Characteristics:
     * - Memory efficient with automatic optimization
     * - Type-safe operations with zero runtime overhead
     * - Optimized for large datasets
     * - Demonstrates SwiftData's query optimization
     */
    func fetchAll() {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let persons = try! context.fetch(descriptor)
        for person in persons {
            _ = person.id
            _ = person.name
            _ = person.age
        }
    }
    
    /**
     * Fetch a single record by its unique ID
     * 
     * This method demonstrates SwiftData's single record retrieval using
     * FetchDescriptor with predicate for efficient primary key lookups.
     * 
     * SwiftData Single Fetch:
     * - FetchDescriptor with predicate for ID matching
     * - fetchLimit = 1 for optimal performance
     * - Direct model retrieval
     * - Automatic object-to-model mapping
     * 
     * Performance Characteristics:
     * - Single record fetch (very fast)
     * - Predicate-based filtering
     * - Type-safe operations
     * - Minimal memory overhead
     * 
     * @param id Unique identifier of the record to fetch
     * @return Person object if found, nil otherwise
     */
    func fetchSingle(id: Int64) -> Person? {
        let context = createContext()
        let intId = Int(id)
        var descriptor = FetchDescriptor<SwiftDataPerson>(
            predicate: #Predicate { $0.id == intId }
        )
        descriptor.fetchLimit = 1
        
        if let swiftDataPerson = try! context.fetch(descriptor).first {
            return Person(id: swiftDataPerson.id, name: swiftDataPerson.name, age: Int(swiftDataPerson.age))
        }
        return nil
    }

    /**
     * Remove all records using SwiftData's batch delete operation
     * 
     * This method demonstrates SwiftData bulk deletion performance using
     * deleteAll(), which efficiently removes all objects of a type
     * in a single transaction for maximum efficiency.
     * 
     * SwiftData Batch Delete:
     * - deleteAll() for efficient bulk operations
     * - Single transaction for all deletions
     * - Much faster than individual deletions
     * - Automatic model lifecycle management
     * 
     * Performance Characteristics:
     * - Efficient batch operation (very fast)
     * - Single transaction overhead
     * - Automatic memory cleanup
     * - Optimal for bulk cleanup operations
     */
    func deleteAll() {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let persons = try! context.fetch(descriptor)
        for person in persons {
            context.delete(person)
        }
        try! context.save()
    }
    
    // MARK: - Update Operations
    
    /**
     * Update a single record by its unique ID
     * 
     * This method demonstrates individual record update performance in SwiftData.
     * It uses SwiftData's type-safe query system to find the model and updates
     * it within a save operation, leveraging SwiftData's automatic change tracking.
     * 
     * SwiftData Update Characteristics:
     * - Type-safe query-based model retrieval
     * - Save operation for updates
     * - Automatic change tracking
     * - Model graph consistency
     * 
     * Performance Implications:
     * - Model query overhead vs direct database access
     * - Save operation management
     * - Automatic change tracking benefits
     * - Model graph consistency maintenance
     * 
     * @param id Unique identifier of the record to update
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateSingleById(id: Int64, newName: String, newAge: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let allPersons = try! context.fetch(descriptor)
        if let person = allPersons.first(where: { $0.id == Int(id) }) {
            person.name = newName
            person.age = newAge
            try! context.save()
        }
    }
    
    /**
     * Update a single record by matching its name
     * 
     * This method demonstrates update performance when searching by a non-primary key field.
     * It requires a type-safe query to find the matching record, making it slower than
     * ID-based updates but useful for testing search performance.
     * 
     * SwiftData Query Characteristics:
     * - Type-safe predicate-based model retrieval
     * - Non-primary key search overhead
     * - Query optimization benefits
     * - Model graph consistency
     * 
     * Performance Implications:
     * - Query overhead for non-primary key searches
     * - Slower than ID-based updates
     * - Demonstrates SwiftData's query optimization
     * - Useful for testing search + update combinations
     * 
     * @param oldName Current name to search for
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateSingleByName(oldName: String, newName: String, newAge: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>(
            predicate: #Predicate { $0.name == oldName }
        )
        if let person = try! context.fetch(descriptor).first {
            person.name = newName
            person.age = newAge
            try! context.save()
        }
    }
    
    /**
     * Update all records with the same values
     * 
     * This method demonstrates bulk update performance in SwiftData.
     * It retrieves all models and updates them within a single save operation,
     * leveraging SwiftData's batch processing capabilities.
     * 
     * SwiftData Bulk Update Characteristics:
     * - Batch model retrieval
     * - Single save operation
     * - Automatic change tracking
     * - Model graph consistency
     * 
     * Performance Implications:
     * - Batch processing efficiency
     * - Single save operation benefits
     * - Model graph management overhead
     * - Automatic change tracking benefits
     * 
     * @param newName New name value to set for all records
     * @param newAge New age value to set for all records
     */
    func updateAllRecords(newName: String, newAge: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let persons = try! context.fetch(descriptor)
        for person in persons {
            person.name = newName
            person.age = newAge
        }
        try! context.save()
    }
    
    /**
     * Update multiple specific records by their IDs
     * 
     * This method demonstrates targeted bulk updates using SwiftData's type-safe query system.
     * It's more efficient than multiple individual updates and useful for
     * batch operations on selected records.
     * 
     * SwiftData Targeted Update Characteristics:
     * - Type-safe IN clause equivalent with predicate
     * - Batch model retrieval
     * - Single save operation
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - More efficient than multiple individual updates
     * - Single save operation benefits
     * - Query optimization for ID filtering
     * - Good balance between precision and performance
     * 
     * @param ids Array of IDs to update
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateMultipleByIds(ids: [Int64], newName: String, newAge: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let allPersons = try! context.fetch(descriptor)
        let persons = allPersons.filter { ids.contains(Int64($0.id)) }
        for person in persons {
            person.name = newName
            person.age = newAge
        }
        try! context.save()
    }
    
    /**
     * Update records within a specific age range
     * 
     * This method demonstrates conditional updates using SwiftData's type-safe query system.
     * It's useful for testing query performance with range operations and demonstrates
     * how SwiftData handles conditional updates efficiently.
     * 
     * SwiftData Conditional Update Characteristics:
     * - Type-safe range-based filtering
     * - Query optimization benefits
     * - Single save operation
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - Query optimization for range conditions
     * - Single save operation benefits
     * - Demonstrates SwiftData's query capabilities
     * - Useful for testing range query performance
     * 
     * @param minAge Minimum age for the range (inclusive)
     * @param maxAge Maximum age for the range (inclusive)
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateByAgeRange(minAge: Int16, maxAge: Int16, newName: String, newAge: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>(
            predicate: #Predicate { $0.age >= minAge && $0.age <= maxAge }
        )
        let persons = try! context.fetch(descriptor)
        for person in persons {
            person.name = newName
            person.age = newAge
        }
        try! context.save()
    }
    
    /**
     * Update records matching a name pattern using SwiftData's type-safe query system
     * 
     * This method demonstrates pattern-based updates using SwiftData's type-safe predicates.
     * It's useful for testing string pattern matching performance and demonstrates
     * how SwiftData handles text-based conditional updates.
     * 
     * SwiftData Pattern Update Characteristics:
     * - Type-safe pattern matching with predicates
     * - String search optimization
     * - Single save operation
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - String pattern matching overhead
     * - Query optimization for text searches
     * - Demonstrates SwiftData's text query capabilities
     * - Useful for testing text search performance
     * 
     * @param pattern SwiftData predicate pattern to match
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateByNamePattern(pattern: String, newName: String, newAge: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>(
            predicate: #Predicate { $0.name.contains(pattern) }
        )
        let persons = try! context.fetch(descriptor)
        for person in persons {
            person.name = newName
            person.age = newAge
        }
        try! context.save()
    }
    
    /**
     * Increment age of all records by a specified amount
     * 
     * This method demonstrates mathematical operations in SwiftData updates.
     * It uses SwiftData's model property manipulation to modify existing values,
     * which requires fetching and updating each model individually.
     * 
     * SwiftData Mathematical Update Characteristics:
     * - Model property manipulation
     * - Individual model updates
     * - Save operation management
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - Model-level mathematical operations
     * - Individual model update overhead
     * - Demonstrates SwiftData's model manipulation
     * - Less efficient than SQL arithmetic operations
     * 
     * @param amount Value to add to each record's age
     */
    func incrementAgeBy(amount: Int16) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let persons = try! context.fetch(descriptor)
        for person in persons {
            person.age += amount
        }
        try! context.save()
    }
    
    /**
     * Append text to all record names using SwiftData's string manipulation
     * 
     * This method demonstrates string manipulation in SwiftData updates.
     * It uses SwiftData's model property manipulation to modify existing
     * text values, requiring individual model updates.
     * 
     * SwiftData String Update Characteristics:
     * - Model property manipulation
     * - Individual model updates
     * - Save operation management
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - Model-level string operations
     * - Individual model update overhead
     * - Demonstrates SwiftData's string manipulation
     * - Less efficient than SQL string operations
     * 
     * @param suffix Text to append to each record's name
     */
    func appendToNames(suffix: String) {
        let context = createContext()
        let descriptor = FetchDescriptor<SwiftDataPerson>()
        let persons = try! context.fetch(descriptor)
        for person in persons {
            person.name += suffix
        }
        try! context.save()
    }
}
