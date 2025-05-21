import Foundation
import CoreData

@objc(Story)
public class Story: NSManagedObject {
    // Override awakeFromInsert to set a new UUID when the object is first inserted.
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID() // Set the id to a new UUID
        self.title = self.title ?? "Default Story Title"
    }
}
