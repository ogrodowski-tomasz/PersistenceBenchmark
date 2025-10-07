import Foundation
import CoreData

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
