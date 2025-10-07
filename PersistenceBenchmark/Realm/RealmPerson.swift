import Foundation
import RealmSwift

/**
 * RealmPerson - Realm Object Model for Benchmarking
 * 
 * This class represents a Person entity in Realm database, providing
 * the object model for performance testing. It inherits from Object
 * to enable Realm's automatic persistence and change tracking.
 * 
 * Realm Object Features:
 * - Automatic persistence and change tracking
 * - Primary key support for efficient lookups
 * - Property types optimized for Realm storage
 * - Automatic schema management
 * 
 * Performance Characteristics:
 * - Zero-copy object access
 * - Automatic memory management
 * - Built-in query optimization
 * - Relationship support
 */
class RealmPerson: Object {
    @Persisted var id: Int = 0
    @Persisted var name: String = ""
    @Persisted var age: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
