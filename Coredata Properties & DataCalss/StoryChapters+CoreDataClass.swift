import Foundation
import CoreData

@objc(StoryChapters)
public class StoryChapters: NSManagedObject {
    
    // Override awakeFromInsert to set a UUID when the object is first inserted into the context.
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Use primitive value setting for Core Data properties
        self.setPrimitiveValue(UUID(), forKey: "id")
        
        // Only set title if it's nil
        if self.primitiveValue(forKey: "title") == nil {
            self.setPrimitiveValue("Default Chapter Title", forKey: "title")
        }
    }
}

