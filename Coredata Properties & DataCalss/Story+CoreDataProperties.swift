import Foundation
import CoreData

extension Story {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Story> {
        return NSFetchRequest<Story>(entityName: "Story")
    }

    @NSManaged public var author: String?
    @NSManaged public var chapterNumber: Int64
    @NSManaged public var character: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date? // Assuming this should be a Date, not String
    @NSManaged public var id: UUID? // Changed from String to UUID
    @NSManaged public var isAudioAvailable: Bool
    @NSManaged public var recordName: String?
    @NSManaged public var storyChapters: Int64
    @NSManaged public var summary: String?
    @NSManaged public var title: String?
    @NSManaged public var audiobooks: Audiobooks? // Assuming you have an entity named Audiobook
    @NSManaged public var characters: NSSet?
    @NSManaged public var ownership: Ownership?
    @NSManaged public var ratings: Ratings? // Assuming you have an entity named Rating
    @NSManaged public var storychapters: NSSet?
}

// MARK: Generated accessors for characters
extension Story {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Characters)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Characters)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}

// MARK: Generated accessors for storychapters
extension Story {

    @objc(addStorychaptersObject:)
    @NSManaged public func addToStorychapters(_ value: StoryChapters)

    @objc(removeStorychaptersObject:)
    @NSManaged public func removeFromStorychapters(_ value: StoryChapters)

    @objc(addStorychapters:)
    @NSManaged public func addToStorychapters(_ values: NSSet)

    @objc(removeStorychapters:)
    @NSManaged public func removeFromStorychapters(_ values: NSSet)

}

extension Story : Identifiable {

}
