
import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var characters: String?
    @NSManaged public var content: String?
    @NSManaged public var genre: String?
    @NSManaged public var publishdate: Date?
    @NSManaged public var summary: String?
    @NSManaged public var title: String?
    @NSManaged public var id: UUID?
    @NSManaged public var storychapters: NSSet?

}

// MARK: Generated accessors for storychapters
extension Book {

    @objc(addStorychaptersObject:)
    @NSManaged public func addToStorychapters(_ value: StoryChapters)

    @objc(removeStorychaptersObject:)
    @NSManaged public func removeFromStorychapters(_ value: StoryChapters)

    @objc(addStorychapters:)
    @NSManaged public func addToStorychapters(_ values: NSSet)

    @objc(removeStorychapters:)
    @NSManaged public func removeFromStorychapters(_ values: NSSet)

}

extension Book : Identifiable {

}
