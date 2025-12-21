import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)

    private let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Loomiverse")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure CloudKit options to reduce sync issues
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            
            // CloudKit configuration
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // Performance optimizations
            description.setOption("WAL" as NSString, forKey: NSSQLitePragmasOption)
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        
        // Configure view context for better performance
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    // Public getter for the container to be used where needed
    func getContainer() -> NSPersistentCloudKitContainer {
        return container
    }

    func getDatabaseURL() -> URL? {
        guard let url = container.persistentStoreCoordinator.persistentStores.first?.url else {
            print("No persistent stores found.")
            return nil
        }
        return url
    }
}
