//
//  StoryChapters+CoreDataProperties.swift
//  Loomiverse
//
//  Created by Danny Jones Photography on 4/26/24.
//
//

import Foundation
import CoreData


extension StoryChapters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryChapters> {
        return NSFetchRequest<StoryChapters>(entityName: "StoryChapters")
    }

    @NSManaged public var chapterNumber: Int32
    @NSManaged public var content: String?
    @NSManaged public var id: UUID?
    @NSManaged public var orderIndex: Int32
    @NSManaged public var recordName: String?
    @NSManaged public var title: String?
    @NSManaged public var book: Book?
    @NSManaged public var characters: NSSet?
    @NSManaged public var story: Story?

}

// MARK: Generated accessors for characters
extension StoryChapters {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Characters)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Characters)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}

extension StoryChapters : Identifiable {

}
