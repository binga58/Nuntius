//
//  NTMessage+CoreDataProperties.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NTMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NTMessage> {
        return NSFetchRequest<NTMessage>(entityName: "NTMessage")
    }

    @NSManaged public var messageId: String?
    @NSManaged public var messageText: String?
    @NSManaged public var createdTimestamp: NSNumber?
    @NSManaged public var deliveredTimestamp: NSNumber?
    @NSManaged public var readTimestamp: NSNumber?
    @NSManaged public var messageStatus: NSNumber?
    @NSManaged public var isMine: NSNumber?
    @NSManaged public var messageType: Double
    @NSManaged public var userId: String?
    @NSManaged public var groupId: String?

}
