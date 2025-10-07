import Foundation
import SQLite3

/**
 * SQLiteManager - Direct SQLite Database Implementation
 * 
 * This class provides a low-level SQLite database interface using the C API.
 * It implements the DatabaseManager protocol to enable performance comparison
 * with Core Data. All operations use prepared statements for security and performance.
 * 
 * Key Features:
 * - Direct SQLite C API usage for maximum performance
 * - Prepared statements to prevent SQL injection
 * - Proper memory management with finalize calls
 * - Transaction support for bulk operations
 * - Temporary database storage for benchmark isolation
 */
final class SQLiteManager: DatabaseManager {

    /// Database connection pointer - OpaquePointer is required for C API compatibility
    private var db: OpaquePointer?

    /**
     * Initialize SQLite database connection and create table structure
     * 
     * This constructor establishes a connection to a temporary SQLite database
     * and ensures the required table schema exists. The database is stored in
     * the system's temporary directory and will be automatically cleaned up.
     */
    init() {
        openDatabase()
        createTableIfNeeded()
    }

    // MARK: - DatabaseManager Protocol Implementation

    /**
     * Insert records one by one without transaction grouping
     * 
     * This method demonstrates individual record insertion performance.
     * Each record is inserted with its own database transaction, which
     * is slower but simpler than bulk operations. Used to measure the
     * overhead of individual database commits.
     * 
     * Performance Characteristics:
     * - Each insert triggers a separate database commit
     * - Higher overhead due to transaction management per record
     * - Simpler error handling (failures are isolated)
     * - Better for small datasets or when individual control is needed
     * 
     * @param data Array of Person objects to insert
     */
    func insertSingle(data: [Person]) {
        deleteAll()
        for person in data {
            insert(person: person)
        }
    }

    /**
     * Insert all records within a single database transaction
     * 
     * This method demonstrates bulk insertion performance using SQLite transactions.
     * All records are inserted within a single BEGIN/COMMIT transaction block,
     * which provides significant performance improvements over individual inserts.
     * 
     * Performance Characteristics:
     * - Single transaction for all records (much faster)
     * - Atomic operation (all succeed or all fail)
     * - Minimal database I/O overhead
     * - Optimal for bulk data operations
     * 
     * @param data Array of Person objects to insert
     */
    func insertBulk(data: [Person]) {
        deleteAll()
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        for person in data {
            insert(person: person)
        }
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    /**
     * Retrieve all records from the database
     * 
     * This method fetches all Person records using a prepared SELECT statement.
     * The data is read row by row using the SQLite C API, which provides
     * direct access to database values without object creation overhead.
     * 
     * Performance Characteristics:
     * - Direct database access (no object graph overhead)
     * - Memory efficient (only loads data as needed)
     * - Fast iteration through result set
     * - No Core Data object management overhead
     */
    func fetchAll() {
        let query = "SELECT id, name, age FROM Person;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, query, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            _ = sqlite3_column_int(stmt, 0)      // Read id column
            _ = sqlite3_column_text(stmt, 1)     // Read name column  
            _ = sqlite3_column_int(stmt, 2)      // Read age column
        }
        sqlite3_finalize(stmt)
    }
    
    /**
     * Fetch a single record by its unique ID
     * 
     * This method demonstrates SQLite's single record retrieval using
     * prepared statements with parameter binding for optimal performance.
     * 
     * SQLite Single Fetch:
     * - Prepared statement with parameter binding
     * - WHERE clause with ID matching
     * - Direct column value extraction
     * - Manual object-to-model mapping
     * 
     * Performance Characteristics:
     * - Single record fetch (very fast)
     * - Index-based lookup (primary key)
     * - Minimal memory overhead
     * - Direct database access
     * 
     * @param id Unique identifier of the record to fetch
     * @return Person object if found, nil otherwise
     */
    func fetchSingle(id: Int64) -> Person? {
        let query = "SELECT id, name, age FROM Person WHERE id = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, query, -1, &stmt, nil)
        sqlite3_bind_int64(stmt, 1, id)
        
        var result: Person? = nil
        if sqlite3_step(stmt) == SQLITE_ROW {
            let fetchedId = sqlite3_column_int64(stmt, 0)
            let namePtr = sqlite3_column_text(stmt, 1)
            let name = namePtr != nil ? String(cString: namePtr!) : ""
            let age = sqlite3_column_int(stmt, 2)
            
            result = Person(id: Int(fetchedId), name: name, age: Int(age))
        }
        
        sqlite3_finalize(stmt)
        return result
    }

    /**
     * Remove all records from the database
     * 
     * This method performs a bulk delete operation using a single SQL statement.
     * It's much faster than deleting individual records and is used to reset
     * the database state between benchmark runs.
     * 
     * Performance Characteristics:
     * - Single SQL DELETE statement (very fast)
     * - No need to load objects into memory
     * - Direct database operation
     * - Minimal I/O overhead
     */
    func deleteAll() {
        sqlite3_exec(db, "DELETE FROM Person;", nil, nil, nil)
    }
    
    // MARK: - Update Operations
    
    /**
     * Update a single record by its unique ID
     * 
     * This method demonstrates individual record update performance using a WHERE clause
     * to target a specific record. It uses prepared statements for security and performance.
     * 
     * Performance Characteristics:
     * - Direct SQL UPDATE with WHERE clause
     * - Single record targeted (very fast)
     * - Prepared statement prevents SQL injection
     * - Minimal database I/O overhead
     * 
     * @param id Unique identifier of the record to update
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateSingleById(id: Int64, newName: String, newAge: Int16) {
        let updateSQL = "UPDATE Person SET name = ?, age = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (newName as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(newAge))
        sqlite3_bind_int64(stmt, 3, id)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Update a single record by matching its name
     * 
     * This method demonstrates update performance when searching by a non-primary key field.
     * It requires a full table scan to find the matching record, making it slower than
     * ID-based updates but useful for testing search performance.
     * 
     * Performance Characteristics:
     * - Requires table scan to find matching name
     * - Slower than ID-based updates
     * - Demonstrates non-indexed field performance
     * - Useful for testing search + update combinations
     * 
     * @param oldName Current name to search for
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateSingleByName(oldName: String, newName: String, newAge: Int16) {
        let updateSQL = "UPDATE Person SET name = ?, age = ? WHERE name = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (newName as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(newAge))
        sqlite3_bind_text(stmt, 3, (oldName as NSString).utf8String, -1, nil)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Update all records in the database with the same values
     * 
     * This method demonstrates bulk update performance without WHERE clauses.
     * It updates every record in the table, which is useful for mass data changes
     * and testing the performance difference between targeted and bulk operations.
     * 
     * Performance Characteristics:
     * - Updates all records in single operation
     * - No WHERE clause filtering (processes entire table)
     * - Very fast for bulk data changes
     * - Demonstrates raw SQL performance
     * 
     * @param newName New name value to set for all records
     * @param newAge New age value to set for all records
     */
    func updateAllRecords(newName: String, newAge: Int16) {
        let updateSQL = "UPDATE Person SET name = ?, age = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (newName as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(newAge))
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Update multiple specific records by their IDs
     * 
     * This method demonstrates targeted bulk updates using an IN clause.
     * It's more efficient than multiple individual updates and useful for
     * batch operations on selected records.
     * 
     * Performance Characteristics:
     * - Single SQL statement with IN clause
     * - More efficient than multiple individual updates
     * - Demonstrates SQL IN clause performance
     * - Good balance between precision and performance
     * 
     * @param ids Array of IDs to update
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateMultipleByIds(ids: [Int64], newName: String, newAge: Int16) {
        // Create placeholders for IN clause - dynamic SQL generation
        let placeholders = ids.map { _ in "?" }.joined(separator: ",")
        let updateSQL = "UPDATE Person SET name = ?, age = ? WHERE id IN (\(placeholders));"
        
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (newName as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(newAge))
        
        // Bind all the IDs to their respective placeholders
        for (index, id) in ids.enumerated() {
            sqlite3_bind_int64(stmt, Int32(index + 3), id)
        }
        
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Update records within a specific age range
     * 
     * This method demonstrates conditional updates using WHERE clauses with range conditions.
     * It's useful for testing query performance with range operations and demonstrates
     * how SQLite handles conditional updates efficiently.
     * 
     * Performance Characteristics:
     * - WHERE clause with range conditions
     * - Tests query optimization with ranges
     * - Demonstrates conditional update performance
     * - Useful for testing index effectiveness
     * 
     * @param minAge Minimum age for the range (inclusive)
     * @param maxAge Maximum age for the range (inclusive)
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateByAgeRange(minAge: Int16, maxAge: Int16, newName: String, newAge: Int16) {
        let updateSQL = "UPDATE Person SET name = ?, age = ? WHERE age >= ? AND age <= ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (newName as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(newAge))
        sqlite3_bind_int(stmt, 3, Int32(minAge))
        sqlite3_bind_int(stmt, 4, Int32(maxAge))
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Update records matching a name pattern using LIKE operator
     * 
     * This method demonstrates pattern-based updates using SQL LIKE operator.
     * It's useful for testing string pattern matching performance and demonstrates
     * how SQLite handles text-based conditional updates.
     * 
     * Performance Characteristics:
     * - LIKE operator for pattern matching
     * - Tests string search performance
     * - Demonstrates text-based conditional updates
     * - Useful for testing text index effectiveness
     * 
     * @param pattern SQL LIKE pattern to match (e.g., "John%", "%Smith")
     * @param newName New name value to set
     * @param newAge New age value to set
     */
    func updateByNamePattern(pattern: String, newName: String, newAge: Int16) {
        let updateSQL = "UPDATE Person SET name = ?, age = ? WHERE name LIKE ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (newName as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(newAge))
        sqlite3_bind_text(stmt, 3, (pattern as NSString).utf8String, -1, nil)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Increment age of all records by a specified amount
     * 
     * This method demonstrates mathematical operations in SQL updates.
     * It uses SQL's arithmetic capabilities to modify existing values,
     * which is more efficient than fetching, modifying, and updating.
     * 
     * Performance Characteristics:
     * - SQL arithmetic operations (very fast)
     * - No need to fetch current values
     * - Database-level computation
     * - Demonstrates SQL mathematical capabilities
     * 
     * @param amount Value to add to each record's age
     */
    func incrementAgeBy(amount: Int16) {
        let updateSQL = "UPDATE Person SET age = age + ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_int(stmt, 1, Int32(amount))
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    
    /**
     * Append text to all record names using SQL string concatenation
     * 
     * This method demonstrates string manipulation in SQL updates.
     * It uses SQL's string concatenation operator (||) to modify existing
     * text values without fetching them first.
     * 
     * Performance Characteristics:
     * - SQL string operations (very fast)
     * - No need to fetch current values
     * - Database-level string manipulation
     * - Demonstrates SQL string capabilities
     * 
     * @param suffix Text to append to each record's name
     */
    func appendToNames(suffix: String) {
        let updateSQL = "UPDATE Person SET name = name || ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, updateSQL, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, (suffix as NSString).utf8String, -1, nil)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }

    // MARK: - Helper Methods

    /**
     * Insert a single Person record into the database
     * 
     * This private helper method handles the core insertion logic using prepared statements.
     * It's used by both single and bulk insert operations to ensure consistent
     * parameter binding and error handling.
     * 
     * Implementation Details:
     * - Uses prepared statements for security and performance
     * - Binds parameters in the correct order (id, name, age)
     * - Handles string conversion to C strings for SQLite
     * - Properly finalizes statements to prevent memory leaks
     * 
     * @param person Person object to insert into the database
     */
    private func insert(person: Person) {
        let insertSQL = "INSERT INTO Person (id, name, age) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil)
        sqlite3_bind_int(stmt, 1, Int32(person.id))
        sqlite3_bind_text(stmt, 2, (person.name as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 3, Int32(person.age))
        sqlite3_step(stmt) // Execute prepared statement
        sqlite3_finalize(stmt) // Clean up memory used by statement. Prevents memory leaks.
    }

    // MARK: - Database Setup and Management

    /**
     * Establish connection to SQLite database file
     * 
     * This method creates a connection to a temporary SQLite database file.
     * The database is stored in the system's temporary directory, which ensures
     * automatic cleanup when the app terminates. This isolation prevents
     * interference with other database operations.
     * 
     * Database Location:
     * - Uses NSTemporaryDirectory() for automatic cleanup
     * - File name: "benchmark.sqlite"
     * - Full path: /tmp/benchmark.sqlite (varies by system)
     * 
     * Error Handling:
     * - Fatal error if database cannot be opened
     * - Ensures benchmark reliability by failing fast
     */
    private func openDatabase() {
        let path = NSTemporaryDirectory() + "benchmark.sqlite"
        if sqlite3_open(path, &db) != SQLITE_OK {
            fatalError("Unable to open SQLite database at \(path)")
        }
    }

    /**
     * Create the Person table schema if it doesn't exist
     * 
     * This method ensures the required table structure exists before any operations.
     * It uses the IF NOT EXISTS clause to prevent errors if the table already exists.
     * The schema is designed to match the Person model structure.
     * 
     * Table Schema:
     * - id: INTEGER PRIMARY KEY (auto-incrementing, unique identifier)
     * - name: TEXT (variable-length string for person names)
     * - age: INTEGER (whole number for person ages)
     * 
     * Design Decisions:
     * - PRIMARY KEY on id for fast lookups and uniqueness
     * - TEXT for names to handle variable-length strings
     * - INTEGER for ages to match Person model
     */
    private func createTableIfNeeded() {
        let createSQL = """
        CREATE TABLE IF NOT EXISTS Person(
            id INTEGER PRIMARY KEY,
            name TEXT,
            age INTEGER
        );
        """
        sqlite3_exec(db, createSQL, nil, nil, nil)
    }

    /**
     * Clean up database connection and free resources
     * 
     * This deinitializer ensures proper cleanup of the SQLite database connection.
     * It's called automatically when the SQLiteManager instance is deallocated,
     * preventing memory leaks and ensuring database file handles are properly closed.
     * 
     * Cleanup Process:
     * - Closes the database connection
     * - Frees all associated memory
     * - Ensures file handles are released
     * - Prevents resource leaks
     */
    deinit {
        sqlite3_close(db)
    }
}
