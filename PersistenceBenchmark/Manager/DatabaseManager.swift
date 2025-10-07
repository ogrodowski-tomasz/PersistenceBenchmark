import Foundation

/**
 * DatabaseManager Protocol - Common Interface for Persistence Implementations
 *
 * This protocol defines the standard interface that Core Data, Realm, SwiftData and SQLite
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
