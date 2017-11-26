//
//  NTUserData+CoreDataProperties.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 25/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NTUserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NTUserData> {
        return NSFetchRequest<NTUserData>(entityName: "NTUserData")
    }

    @NSManaged public var userId: String?
    @NSManaged public var userName: String?
    @NSManaged public var presence: NSNumber?
    @NSManaged public var status: NSNumber?
    @NSManaged public var hasMessages: NSSet?
    @NSManaged public var hasGroup: NTGroupData?

}

// MARK: Generated accessors for hasMessages
extension NTUserData {

    @objc(addHasMessagesObject:)
    @NSManaged public func addToHasMessages(_ value: NTMessageData)

    @objc(removeHasMessagesObject:)
    @NSManaged public func removeFromHasMessages(_ value: NTMessageData)

    @objc(addHasMessages:)
    @NSManaged public func addToHasMessages(_ values: NSSet)

    @objc(removeHasMessages:)
    @NSManaged public func removeFromHasMessages(_ values: NSSet)

}
