import SwiftUI
import CoreData

@main
struct LoomiverseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView().environment(\.managedObjectContext, persistenceController.getContainer().viewContext)
        }
    }
}
