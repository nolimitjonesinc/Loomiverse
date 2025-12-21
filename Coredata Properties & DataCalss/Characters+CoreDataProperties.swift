import Foundation
import CoreData

// Import the Core Data module for StoryChapters entity

extension Characters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Characters> {
        return NSFetchRequest<Characters>(entityName: "Characters")
    }

    @NSManaged public var age: Int32
    @NSManaged public var ancestry: NSObject?
    @NSManaged public var backstory: String?
    @NSManaged public var careerSkills: NSObject?
    @NSManaged public var emotionalMaturity: Double
    @NSManaged public var gender: String?
    @NSManaged public var id: UUID? // Change type from String? to UUID?
    @NSManaged public var interests: NSObject?
    @NSManaged public var lifeExperiences: NSObject?
    @NSManaged public var moralAlignment: Double
    @NSManaged public var name: String?
    @NSManaged public var personalityTraits: NSObject?
    @NSManaged public var physicality: NSObject?
    @NSManaged public var psychologicalComplexities: NSObject?
    @NSManaged public var socialRelationships: NSObject?
    @NSManaged public var relationships: NSSet?
    @NSManaged public var story: Story?
    @NSManaged public var storychapters: NSSet?

}

// MARK: Generated accessors for relationships
extension Characters {

    @objc(addRelationshipsObject:)
    @NSManaged public func addToRelationships(_ value: Relationships)

    @objc(removeRelationshipsObject:)
    @NSManaged public func removeFromRelationships(_ value: Relationships)

    @objc(addRelationships:)
    @NSManaged public func addToRelationships(_ values: NSSet)

    @objc(removeRelationships:)
    @NSManaged public func removeFromRelationships(_ values: NSSet)

}

// MARK: Generated accessors for storychapters
extension Characters {

    @objc(addStorychaptersObject:)
    @NSManaged public func addToStorychapters(_ value: NSManagedObject)
    
    // Helper method to add a typed StoryChapters entity
    func addChapter(_ chapter: NSManagedObject) {
        addToStorychapters(chapter)
    }

    @objc(removeStorychaptersObject:)
    @NSManaged public func removeFromStorychapters(_ value: NSManagedObject)
    
    // Helper method to remove a typed StoryChapters entity
    func removeChapter(_ chapter: NSManagedObject) {
        removeFromStorychapters(chapter)
    }

    @objc(addStorychapters:)
    @NSManaged public func addToStorychapters(_ values: NSSet)

    @objc(removeStorychapters:)
    @NSManaged public func removeFromStorychapters(_ values: NSSet)

}

extension Characters : Identifiable {

}
