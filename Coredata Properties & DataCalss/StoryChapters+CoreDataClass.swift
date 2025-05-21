import Foundation
import CoreData

@objc(StoryChapters)
public class StoryChapters: NSManagedObject {
    
    // Override awakeFromInsert to set a UUID when the object is first inserted into the context.
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID() // Set the id to a new UUID
        self.title = self.title ?? "Default Chapter Title"
    }
}

