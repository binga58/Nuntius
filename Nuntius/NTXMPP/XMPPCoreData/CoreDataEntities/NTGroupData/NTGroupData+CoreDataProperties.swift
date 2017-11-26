//
//  NTGroupData+CoreDataProperties.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 25/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NTGroupData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NTGroupData> {
        return NSFetchRequest<NTGroupData>(entityName: "NTGroupData")
    }

    @NSManaged public var groupId: String?
    @NSManaged public var groupName: String?
    @NSManaged public var adminId: String?
    @NSManaged public var hasMessages: NSSet?
    @NSManaged public var hasUsers: NSSet?

}

// MARK: Generated accessors for hasMessages
extension NTGroupData {

    @objc(addHasMessagesObject:)
    @NSManaged public func addToHasMessages(_ value: NTMessageData)

    @objc(removeHasMessagesObject:)
    @NSManaged public func removeFromHasMessages(_ value: NTMessageData)

    @objc(addHasMessages:)
    @NSManaged public func addToHasMessages(_ values: NSSet)

    @objc(removeHasMessages:)
    @NSManaged public func removeFromHasMessages(_ values: NSSet)

}

// MARK: Generated accessors for hasUsers
extension NTGroupData {

    @objc(addHasUsersObject:)
    @NSManaged public func addToHasUsers(_ value: NTUserData)

    @objc(removeHasUsersObject:)
    @NSManaged public func removeFromHasUsers(_ value: NTUserData)

    @objc(addHasUsers:)
    @NSManaged public func addToHasUsers(_ values: NSSet)

    @objc(removeHasUsers:)
    @NSManaged public func removeFromHasUsers(_ values: NSSet)

}
