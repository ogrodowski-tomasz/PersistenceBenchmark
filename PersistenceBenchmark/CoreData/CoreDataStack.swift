
import Foundation
import CoreData

/**
 * DatabaseManager Protocol - Common Interface for Persistence Implementations
 * 
 * This protocol defines the standard interface that both Core Data and SQLite
 * implementations must follow. It enables fair performance comparison by ensuring
 * both implementations perform identical operations with the same method signatures.
 * 
 * Protocol Design:
 * - CRUD operations (Create, Read, Update, Delete)
 * - Both single and bulk operation variants
 * - Update operations with various targeting strategies
 * - Consistent parameter types across implementations
 * 
 * Performance Testing Focus:
 * - Insert operations (single vs bulk)
 * - Update operations (various targeting methods)
 * - Fetch operations (data retrieval)
 * - Delete operations (cleanup and reset)
 */
protocol DatabaseManager {
    // MARK: - Basic CRUD Operations
    
    /// Insert records individually (slower, simpler)
    func insertSingle(data: [Person])
    
    /// Insert all records in a single transaction (faster, more complex)
    func insertBulk(data: [Person])
    
    /// Retrieve all records from the database
    func fetchAll()
    
    /// Retrieve a single record by its unique ID
    func fetchSingle(id: Int64) -> Person?
    
    /// Remove all records from the database
    func deleteAll()
    
    // MARK: - Update Operations
    
    /// Update a single record by its unique ID
    func updateSingleById(id: Int64, newName: String, newAge: Int16)
    
    /// Update a single record by matching its name
    func updateSingleByName(oldName: String, newName: String, newAge: Int16)
    
    /// Update all records with the same values
    func updateAllRecords(newName: String, newAge: Int16)
    
    /// Update multiple specific records by their IDs
    func updateMultipleByIds(ids: [Int64], newName: String, newAge: Int16)
    
    /// Update records within a specific age range
    func updateByAgeRange(minAge: Int16, maxAge: Int16, newName: String, newAge: Int16)
    
    /// Update records matching a name pattern
    func updateByNamePattern(pattern: String, newName: String, newAge: Int16)
    
    /// Increment age of all records by a specified amount
    func incrementAgeBy(amount: Int16)
    
    /// Append text to all record names
    func appendToNames(suffix: String)
}

/**
 * CoreDataManager - Core Data Implementation for Performance Benchmarking
 * 
 * This class provides a high-level Core Data interface using managed objects and contexts.
 * It implements the DatabaseManager protocol to enable performance comparison with
 * raw SQLite operations. All operations use background contexts for thread safety.
 * 
 * Key Features:
 * - Managed object context management
 * - Background context operations for thread safety
 * - Automatic change tracking and faulting
 * - Relationship management and object graph operations
 * - Memory-efficient batch operations
 * 
 * Performance Characteristics:
 * - Object graph overhead vs direct database access
 * - Context management overhead vs direct SQL
 * - Memory management with faulting
 * - Relationship traversal capabilities
 */
final class CoreDataManager: DatabaseManager {

    /// Shared Core Data stack instance for database operations
    private let coreDataStack = CoreDataStack.shared

    /**
     * Insert records one by one with individual context saves
     * 
     * This method demonstrates individual record insertion performance in Core Data.
     * Each record is created as a managed object and saved immediately, which
     * provides individual transaction control but has higher overhead.
     * 
     * Core Data Characteristics:
     * - Each insert creates a managed object
     * - Individual context.save() calls (higher overhead)
     * - Context reset after each save (memory management)
     * - Object graph tracking for each entity
     * 
     * Performance Implications:
     * - Higher overhead due to individual saves
     * - More memory usage due to object creation
     * - Better error isolation (failures are contained)
     * - Useful for small datasets or when individual control is needed
     * 
     * @param data Array of Person objects to insert
     */
    func insertSingle(data: [Person]) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            for person in data {
                let entity = PersonEntity(context: context)
                entity.id = Int64(person.id)
                entity.name = person.name
                entity.age = Int16(person.age)
                try? context.save() // Save after each object
                context.reset() // Clear context to free memory
            }
        }
    }

    /**
     * Insert all records within a single context save operation
     * 
     * This method demonstrates bulk insertion performance in Core Data.
     * All records are created as managed objects in memory, then saved
     * in a single transaction, which is much more efficient than individual saves.
     * 
     * Core Data Characteristics:
     * - All entities created in memory first
     * - Single context.save() call (much faster)
     * - Batch object graph management
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
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            for person in data {
                let entity = PersonEntity(context: context)
                entity.id = Int64(person.id)
                entity.name = person.name
                entity.age = Int16(person.age)
            }
            try? context.save() // Single save for all objects
            context.reset() // Clear context to free memory
        }
    }

    /**
     * Retrieve all records using optimized fetch request
     * 
     * This method demonstrates Core Data fetch performance with optimizations.
     * It uses dictionary results and batch fetching to minimize memory usage
     * and improve performance for large datasets.
     * 
     * Core Data Optimizations:
     * - Dictionary result type (lighter than managed objects)
     * - Batch fetching (loads data in chunks)
     * - Property-specific fetching (only needed fields)
     * - Background context for thread safety
     * 
     * Performance Characteristics:
     * - Memory efficient with batch fetching
     * - No managed object overhead
     * - Optimized for large datasets
     * - Demonstrates Core Data query optimization
     */
    func fetchAll() {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonEntity")
            fetch.resultType = .dictionaryResultType // Lighter than managed objects
            fetch.propertiesToFetch = ["id", "name", "age"] // Only fetch needed properties
            fetch.fetchBatchSize = 500 // Load in batches for memory efficiency
            _ = try? context.fetch(fetch)
        }
    }

    /**
     * Fetch a single record by its unique ID
     * 
     * This method demonstrates Core Data's single record retrieval using
     * NSFetchRequest with NSPredicate for precise record targeting.
     * 
     * Core Data Single Fetch:
     * - NSFetchRequest with NSPredicate for ID matching
     * - fetchLimit = 1 for optimal performance
     * - Direct managed object retrieval
     * - Automatic object-to-model mapping
     * 
     * Performance Characteristics:
     * - Single record fetch (very fast)
     * - Predicate-based filtering
     * - Managed object creation overhead
     * - Automatic faulting and memory management
     * 
     * @param id Unique identifier of the record to fetch
     * @return Person object if found, nil otherwise
     */
    func fetchSingle(id: Int64) -> Person? {
        let context = coreDataStack.newBackgroundContext()
        var result: Person? = nil
        
        context.performAndWait {
            let fetch = NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
            fetch.predicate = NSPredicate(format: "id == %lld", id)
            fetch.fetchLimit = 1
            
            if let personEntity = try? context.fetch(fetch).first {
                result = Person(id: Int(personEntity.id), name: personEntity.name ?? "", age: Int(personEntity.age))
            }
        }
        
        return result
    }
    
    /**
     * Remove all records using batch delete operation
     * 
     * This method demonstrates Core Data bulk deletion performance using
     * NSBatchDeleteRequest, which bypasses the object graph and executes
     * directly on the persistent store for maximum efficiency.
     * 
     * Core Data Batch Delete:
     * - NSBatchDeleteRequest for direct store operations
     * - Bypasses managed object creation
     * - Much faster than individual deletions
     * - Direct SQL execution on persistent store
     * 
     * Performance Characteristics:
     * - Direct database operation (very fast)
     * - No managed object overhead
     * - Single SQL DELETE statement
     * - Optimal for bulk cleanup operations
     */
    func deleteAll() {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
            _ = try? context.execute(deleteRequest)
            try? context.save()
        }
    }
    
    // MARK: - Update Operations
    
    func updateSingleById(id: Int64, newName: String, newAge: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %lld", id)
            fetchRequest.fetchLimit = 1
            
            if let person = try? context.fetch(fetchRequest).first {
                person.name = newName
                person.age = newAge
                try? context.save()
            }
        }
    }
    
    func updateSingleByName(oldName: String, newName: String, newAge: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", oldName)
            fetchRequest.fetchLimit = 1
            
            if let person = try? context.fetch(fetchRequest).first {
                person.name = newName
                person.age = newAge
                try? context.save()
            }
        }
    }
    
    func updateAllRecords(newName: String, newAge: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            let persons = try? context.fetch(fetchRequest)
            
            for person in persons ?? [] {
                person.name = newName
                person.age = newAge
            }
            try? context.save()
        }
    }
    
    func updateMultipleByIds(ids: [Int64], newName: String, newAge: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", ids.map { NSNumber(value: $0) })
            
            let persons = try? context.fetch(fetchRequest)
            for person in persons ?? [] {
                person.name = newName
                person.age = newAge
            }
            try? context.save()
        }
    }
    
    func updateByAgeRange(minAge: Int16, maxAge: Int16, newName: String, newAge: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "age >= %d AND age <= %d", minAge, maxAge)
            
            let persons = try? context.fetch(fetchRequest)
            for person in persons ?? [] {
                person.name = newName
                person.age = newAge
            }
            try? context.save()
        }
    }
    
    func updateByNamePattern(pattern: String, newName: String, newAge: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name LIKE %@", pattern)
            
            let persons = try? context.fetch(fetchRequest)
            for person in persons ?? [] {
                person.name = newName
                person.age = newAge
            }
            try? context.save()
        }
    }
    
    func incrementAgeBy(amount: Int16) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            let persons = try? context.fetch(fetchRequest)
            
            for person in persons ?? [] {
                person.age += amount
            }
            try? context.save()
        }
    }
    
    func appendToNames(suffix: String) {
        let context = coreDataStack.newBackgroundContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            let persons = try? context.fetch(fetchRequest)
            
            for person in persons ?? [] {
                if let currentName = person.name {
                    person.name = currentName + suffix
                }
            }
            try? context.save()
        }
    }
}

final class CoreDataStack {

    static let shared = CoreDataStack()

    private init() {
        persistentContainer = NSPersistentContainer(name: "BenchmarkModel") // Nazwa pliku .xcdatamodeld
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
            print("✅ Core Data store loaded at: \(storeDescription.url?.absoluteString ?? "unknown")")
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    let persistentContainer: NSPersistentContainer

    // MARK: - Contexts

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Tworzy nowy kontekst dla operacji w tle
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Save

    func saveContext(context: NSManagedObjectContext? = nil) {
        let context = context ?? viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Core Data save error: \(error)")
            }
        }
    }
}
