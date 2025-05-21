//
//  Ownership+CoreDataProperties.swift
//  Loomiverse
//
//  Created by Danny Jones Photography on 2/26/24.
//
//

import Foundation
import CoreData


extension Ownership {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ownership> {
        return NSFetchRequest<Ownership>(entityName: "Ownership")
    }

    @NSManaged public var price: NSDecimalNumber?
    @NSManaged public var royalties: Int64
    @NSManaged public var sales: Int64
    @NSManaged public var transactions: String?
    @NSManaged public var id: UUID?
    @NSManaged public var story: Story?
    @NSManaged public var user: Users?

}

extension Ownership : Identifiable {

}
