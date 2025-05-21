//
//  Users+CoreDataProperties.swift
//  Loomiverse
//
//  Created by Danny Jones Photography on 2/26/24.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var email: String?
    @NSManaged public var preferences: String?
    @NSManaged public var profile: String?
    @NSManaged public var profileImage: Data?
    @NSManaged public var rating: Int64
    @NSManaged public var settings: String?
    @NSManaged public var username: String?
    @NSManaged public var id: UUID?
    @NSManaged public var analytics: Analytics?
    @NSManaged public var ownership: Ownership?

}

extension Users : Identifiable {

}
