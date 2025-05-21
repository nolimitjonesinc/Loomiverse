import Foundation
import CoreData

@objc(Characters)
public class Characters: NSManagedObject {
    
    // This override sets the id to a new UUID when an object is first inserted into the managed object context.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID() // Set the id to a new UUID
    }
}
