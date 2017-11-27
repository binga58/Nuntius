//
//  NTUserData+CoreDataProperties.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 27/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NTUserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NTUserData> {
        return NSFetchRequest<NTUserData>(entityName: "NTUserData")
    }

    @NSManaged public var isGroup: NSNumber?
    @NSManaged public var lastMessageId: String?
    @NSManaged public var presence: NSNumber?
    @NSManaged public var userId: String?
    @NSManaged public var lastActivityTime: NSNumber?
    @NSManaged public var hasGroupMessages: NSSet?
    @NSManaged public var hasMessages: NSSet?

}

// MARK: Generated accessors for hasGroupMessages
extension NTUserData {

    @objc(addHasGroupMessagesObject:)
    @NSManaged public func addToHasGroupMessages(_ value: NTMessageData)

    @objc(removeHasGroupMessagesObject:)
    @NSManaged public func removeFromHasGroupMessages(_ value: NTMessageData)

    @objc(addHasGroupMessages:)
    @NSManaged public func addToHasGroupMessages(_ values: NSSet)

    @objc(removeHasGroupMessages:)
    @NSManaged public func removeFromHasGroupMessages(_ values: NSSet)

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
