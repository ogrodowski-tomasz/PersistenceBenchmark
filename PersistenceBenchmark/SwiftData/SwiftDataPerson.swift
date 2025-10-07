import Foundation
import SwiftData

// MARK: - SwiftData Model

/**
 * SwiftDataPerson - SwiftData Model for Benchmarking
 *
 * This class represents a Person entity in SwiftData database, providing
 * the model for performance testing. It uses SwiftData's @Model macro
 * to enable automatic persistence and change tracking.
 *
 * SwiftData Model Features:
 * - @Model macro for automatic persistence
 * - Primary key support for efficient lookups
 * - Property types optimized for SwiftData storage
 * - Automatic schema management
 *
 * Performance Characteristics:
 * - Type-safe model access
 * - Automatic memory management
 * - Built-in query optimization
 * - Relationship support
 */
@Model
class SwiftDataPerson {
    var id: Int
    var name: String
    var age: Int16
    
    init(id: Int, name: String, age: Int16) {
        self.id = id
        self.name = name
        self.age = age
    }
}
