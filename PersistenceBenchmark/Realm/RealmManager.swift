import Foundation
import RealmSwift

/**
 * RealmManager - Realm Database Implementation for Performance Benchmarking
 * 
 * This class provides a high-level Realm interface using Realm objects and transactions.
 * It implements the DatabaseManager protocol to enable performance comparison with
 * Core Data and SQLite operations. All operations use Realm's transaction system.
 * 
 * Key Features:
 * - Realm object management and automatic persistence
 * - Transaction-based operations for data consistency
 * - Automatic schema management and migrations
 * - Memory-efficient object access with lazy loading
 * - Relationship management and object graph operations
 * 
 * Performance Characteristics:
 * - Object-oriented database with automatic persistence
 * - Zero-copy object access for optimal performance
 * - Automatic memory management and object lifecycle
 * - Built-in caching and query optimization
 * - Relationship traversal with automatic faulting
 */
final class RealmManager: DatabaseManager {

    /// Shared Realm instance for database operations
    private let realm: Realm

    /**
     * Initialize Realm database connection and configuration
     * 
     * This constructor establishes a connection to a temporary Realm database
     * and configures it for optimal benchmark performance. The database is stored
     * in the system's temporary directory for automatic cleanup.
     * 
     * Realm Configuration:
     * - In-memory database for maximum performance
     * - Automatic schema management
     * - Optimized for benchmark operations
     * - Temporary storage for isolation
     * 
     * Performance Optimizations:
     * - In-memory storage for fastest access
     * - Automatic object lifecycle management
     * - Built-in query optimization
     * - Zero-copy object access
     * 
     * Thread Safety:
     * - Realm instances are thread-confined
     * - Each operation creates its own Realm instance
     * - Ensures thread safety for benchmark operations
     */
    init() {
        // Store configuration for creating new Realm instances per thread
        var config = Realm.Configuration()
        config.inMemoryIdentifier = "BenchmarkRealm"
        config.deleteRealmIfMigrationNeeded = true
        
        do {
            realm = try Realm(configuration: config)
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    /**
     * Create a new Realm instance for the current thread
     * 
     * This method ensures thread safety by creating a new Realm instance
     * for each operation. Realm instances are thread-confined and cannot
     * be shared across threads.
     * 
     * @return New Realm instance for the current thread
     */
    private func createRealm() -> Realm {
        var config = Realm.Configuration()
        config.inMemoryIdentifier = "BenchmarkRealm"
        config.deleteRealmIfMigrationNeeded = true
        
        do {
            return try Realm(configuration: config)
        } catch {
            fatalError("Failed to create Realm: \(error)")
        }
    }

    // MARK: - DatabaseManager Protocol Implementation

    /**
     * Insert records one by one with individual transactions
     * 
     * This method demonstrates individual record insertion performance in Realm.
     * Each record is created as a Realm object and saved immediately, which
     * provides individual transaction control but has higher overhead.
     * 
     * Realm Characteristics:
     * - Each insert creates a Realm object
     * - Individual write transactions (higher overhead)
     * - Automatic object persistence
     * - Object graph tracking for each entity
     * 
     * Performance Implications:
     * - Higher overhead due to individual transactions
     * - More memory usage due to object creation
     * - Better error isolation (failures are contained)
     * - Useful for small datasets or when individual control is needed
     * 
     * @param data Array of Person objects to insert
     */
    func insertSingle(data: [Person]) {
        deleteAll()
        let realm = createRealm()
        for person in data {
            let realmPerson = RealmPerson()
            realmPerson.id = person.id
            realmPerson.name = person.name
            realmPerson.age = person.age
            
            try! realm.write {
                realm.add(realmPerson)
            }
        }
    }

    /**
     * Insert all records within a single transaction
     * 
     * This method demonstrates bulk insertion performance in Realm.
     * All records are created as Realm objects in memory, then saved
     * in a single transaction, which is much more efficient than individual saves.
     * 
     * Realm Characteristics:
     * - All objects created in memory first
     * - Single write transaction (much faster)
     * - Batch object graph management
     * - Atomic operation (all succeed or all fail)
     * 
     * Performance Implications:
     * - Much faster than individual transactions
     * - Lower database I/O overhead
     * - Better memory efficiency
     * - Optimal for bulk data operations
     * 
     * @param data Array of Person objects to insert
     */
    func insertBulk(data: [Person]) {
        deleteAll()
        let realm = createRealm()
        let realmPersons = data.map { person in
            let realmPerson = RealmPerson()
            realmPerson.id = person.id
            realmPerson.name = person.name
            realmPerson.age = person.age
            return realmPerson
        }
        
        try! realm.write {
            realm.add(realmPersons)
        }
    }

    /**
     * Retrieve all records using Realm's optimized query system
     * 
     * This method demonstrates Realm fetch performance with automatic optimizations.
     * It uses Realm's lazy loading and zero-copy object access to minimize
     * memory usage and improve performance for large datasets.
     * 
     * Realm Optimizations:
     * - Lazy loading of object properties
     * - Zero-copy object access
     * - Automatic query optimization
     * - Built-in caching mechanisms
     * 
     * Performance Characteristics:
     * - Memory efficient with lazy loading
     * - Zero-copy object access
     * - Optimized for large datasets
     * - Demonstrates Realm's query optimization
     */
    func fetchAll() {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self)
        for person in persons {
            _ = person.id
            _ = person.name
            _ = person.age
        }
    }
    
    /**
     * Fetch a single record by its unique ID
     * 
     * This method demonstrates Realm's single record retrieval using
     * object(ofType:forPrimaryKey:) for efficient primary key lookups.
     * 
     * Realm Single Fetch:
     * - object(ofType:forPrimaryKey:) for primary key lookup
     * - Direct object retrieval without query
     * - Automatic object-to-model mapping
     * - Zero-copy object access
     * 
     * Performance Characteristics:
     * - Primary key lookup (very fast)
     * - Index-based access
     * - Zero-copy object access
     * - Minimal memory overhead
     * 
     * @param id Unique identifier of the record to fetch
     * @return Person object if found, nil otherwise
     */
    func fetchSingle(id: Int64) -> Person? {
        let realm = createRealm()
        if let realmPerson = realm.object(ofType: RealmPerson.self, forPrimaryKey: id) {
            return Person(id: realmPerson.id, name: realmPerson.name, age: realmPerson.age)
        }
        return nil
    }

    /**
     * Remove all records using Realm's batch delete operation
     * 
     * This method demonstrates Realm bulk deletion performance using
     * deleteAll(), which efficiently removes all objects of a type
     * in a single transaction for maximum efficiency.
     * 
     * Realm Batch Delete:
     * - deleteAll() for efficient bulk operations
     * - Single transaction for all deletions
     * - Much faster than individual deletions
     * - Automatic object lifecycle management
     * 
     * Performance Characteristics:
     * - Efficient batch operation (very fast)
     * - Single transaction overhead
     * - Automatic memory cleanup
     * - Optimal for bulk cleanup operations
     */
    func deleteAll() {
        let realm = createRealm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    // MARK: - Update Operations
    
    /**
     * Update a single record by its unique ID
     * 
     * This method demonstrates individual record update performance in Realm.
     * It uses Realm's query system to find the object and updates it within
     * a write transaction, leveraging Realm's automatic change tracking.
     * 
     * Realm Update Characteristics:
     * - Query-based object retrieval
     * - Write transaction for updates
     * - Automatic change tracking
     * - Object graph consistency
     * 
     * Performance Implications:
     * - Object query overhead vs direct database access
     * - Write transaction management
     * - Automatic change tracking benefits
     * - Object graph consistency maintenance
     * 
     * @param id Unique identifier of the record to update
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateSingleById(id: Int64, newName: String, newAge: Int16) {
        let realm = createRealm()
        if let person = realm.object(ofType: RealmPerson.self, forPrimaryKey: id) {
            try! realm.write {
                person.name = newName
                person.age = Int(newAge)
            }
        }
    }
    
    /**
     * Update a single record by matching its name
     * 
     * This method demonstrates update performance when searching by a non-primary key field.
     * It requires a query to find the matching record, making it slower than
     * ID-based updates but useful for testing search performance.
     * 
     * Realm Query Characteristics:
     * - Filter-based object retrieval
     * - Non-primary key search overhead
     * - Query optimization benefits
     * - Object graph consistency
     * 
     * Performance Implications:
     * - Query overhead for non-primary key searches
     * - Slower than ID-based updates
     * - Demonstrates Realm's query optimization
     * - Useful for testing search + update combinations
     * 
     * @param oldName Current name to search for
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateSingleByName(oldName: String, newName: String, newAge: Int16) {
        let realm = createRealm()
        if let person = realm.objects(RealmPerson.self).filter("name == %@", oldName).first {
            try! realm.write {
                person.name = newName
                person.age = Int(newAge)
            }
        }
    }
    
    /**
     * Update all records with the same values
     * 
     * This method demonstrates bulk update performance in Realm.
     * It retrieves all objects and updates them within a single transaction,
     * leveraging Realm's batch processing capabilities.
     * 
     * Realm Bulk Update Characteristics:
     * - Batch object retrieval
     * - Single write transaction
     * - Automatic change tracking
     * - Object graph consistency
     * 
     * Performance Implications:
     * - Batch processing efficiency
     * - Single transaction benefits
     * - Object graph management overhead
     * - Automatic change tracking benefits
     * 
     * @param newName New name value to set for all records
     * @param newAge New age value to set for all records
     */
    func updateAllRecords(newName: String, newAge: Int16) {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self)
        try! realm.write {
            for person in persons {
                person.name = newName
                person.age = Int(newAge)
            }
        }
    }
    
    /**
     * Update multiple specific records by their IDs
     * 
     * This method demonstrates targeted bulk updates using Realm's query system.
     * It's more efficient than multiple individual updates and useful for
     * batch operations on selected records.
     * 
     * Realm Targeted Update Characteristics:
     * - IN clause equivalent with filter
     * - Batch object retrieval
     * - Single write transaction
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - More efficient than multiple individual updates
     * - Single transaction benefits
     * - Query optimization for ID filtering
     * - Good balance between precision and performance
     * 
     * @param ids Array of IDs to update
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateMultipleByIds(ids: [Int64], newName: String, newAge: Int16) {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self).filter("id IN %@", ids)
        try! realm.write {
            for person in persons {
                person.name = newName
                person.age = Int(newAge)
            }
        }
    }
    
    /**
     * Update records within a specific age range
     * 
     * This method demonstrates conditional updates using Realm's query system.
     * It's useful for testing query performance with range operations and demonstrates
     * how Realm handles conditional updates efficiently.
     * 
     * Realm Conditional Update Characteristics:
     * - Range-based filtering
     * - Query optimization benefits
     * - Single write transaction
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - Query optimization for range conditions
     * - Single transaction benefits
     * - Demonstrates Realm's query capabilities
     * - Useful for testing range query performance
     * 
     * @param minAge Minimum age for the range (inclusive)
     * @param maxAge Maximum age for the range (inclusive)
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateByAgeRange(minAge: Int16, maxAge: Int16, newName: String, newAge: Int16) {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self).filter("age >= %d AND age <= %d", minAge, maxAge)
        try! realm.write {
            for person in persons {
                person.name = newName
                person.age = Int(newAge)
            }
        }
    }
    
    /**
     * Update records matching a name pattern using Realm's query system
     * 
     * This method demonstrates pattern-based updates using Realm's LIKE operator.
     * It's useful for testing string pattern matching performance and demonstrates
     * how Realm handles text-based conditional updates.
     * 
     * Realm Pattern Update Characteristics:
     * - LIKE operator for pattern matching
     * - String search optimization
     * - Single write transaction
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - String pattern matching overhead
     * - Query optimization for text searches
     * - Demonstrates Realm's text query capabilities
     * - Useful for testing text search performance
     * 
     * @param pattern Realm LIKE pattern to match (e.g., "John*", "*Smith")
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateByNamePattern(pattern: String, newName: String, newAge: Int16) {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self).filter("name LIKE %@", pattern)
        try! realm.write {
            for person in persons {
                person.name = newName
                person.age = Int(newAge)
            }
        }
    }
    
    /**
     * Increment age of all records by a specified amount
     * 
     * This method demonstrates mathematical operations in Realm updates.
     * It uses Realm's object property manipulation to modify existing values,
     * which requires fetching and updating each object individually.
     * 
     * Realm Mathematical Update Characteristics:
     * - Object property manipulation
     * - Individual object updates
     * - Write transaction management
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - Object-level mathematical operations
     * - Individual object update overhead
     * - Demonstrates Realm's object manipulation
     * - Less efficient than SQL arithmetic operations
     * 
     * @param amount Value to add to each record's age
     */
    func incrementAgeBy(amount: Int16) {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self)
        try! realm.write {
            for person in persons {
                person.age += Int(amount)
            }
        }
    }
    
    /**
     * Append text to all record names using Realm's string manipulation
     * 
     * This method demonstrates string manipulation in Realm updates.
     * It uses Realm's object property manipulation to modify existing
     * text values, requiring individual object updates.
     * 
     * Realm String Update Characteristics:
     * - Object property manipulation
     * - Individual object updates
     * - Write transaction management
     * - Automatic change tracking
     * 
     * Performance Implications:
     * - Object-level string operations
     * - Individual object update overhead
     * - Demonstrates Realm's string manipulation
     * - Less efficient than SQL string operations
     * 
     * @param suffix Text to append to each record's name
     */
    func appendToNames(suffix: String) {
        let realm = createRealm()
        let persons = realm.objects(RealmPerson.self)
        try! realm.write {
            for person in persons {
                person.name += suffix
            }
        }
    }
}

// MARK: - Realm Object Model


