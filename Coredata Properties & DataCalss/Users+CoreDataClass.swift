import Foundation
import CoreData

@objc(Users)
public class Users: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        if self.id == nil {
            self.setValue(UUID().uuidString, forKey: "id")
        }
    }
}
