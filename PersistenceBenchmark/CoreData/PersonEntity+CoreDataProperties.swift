import Foundation
import CoreData


extension PersonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonEntity> {
        return NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
    }

    @NSManaged public var age: Int16
    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}

extension PersonEntity : Identifiable {

}
