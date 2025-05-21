import Foundation
import CoreData

@objc(Ownership)
public class Ownership: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        if self.id == nil {
            self.setValue(UUID().uuidString, forKey: "id")
        }
    }
}

