//
//  NTMessageData+CoreDataProperties.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 25/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData


extension NTMessageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NTMessageData> {
        return NSFetchRequest<NTMessageData>(entityName: "NTMessageData")
    }

    @NSManaged public var createdTimestamp: NSNumber?
    @NSManaged public var deliveredTimestamp: NSNumber?
    @NSManaged public var isMine: NSNumber?
    @NSManaged public var messageId: String?
    @NSManaged public var messageStatus: NSNumber?
    @NSManaged public var messageText: String?
    @NSManaged public var messageType: Double
    @NSManaged public var readTimestamp: NSNumber?
    @NSManaged public var hasUser: NTUserData?
    @NSManaged public var hasGroup: NTGroupData?

}
