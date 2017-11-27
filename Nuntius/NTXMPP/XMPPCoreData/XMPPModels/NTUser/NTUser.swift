//
//  NTUser.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 27/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class NTUser: NSObject {
    var userId: String?
    var isGroup: NSNumber?
    var presence: NSNumber?
    var lastMessage: NTMessage?
    var lastMessageId: String?
    
    public init(userData: NTUserData) {
        super.init()
        self.userId = userData.userId
        self.isGroup = userData.isGroup
        self.presence = userData.presence
        self.lastMessageId = userData.lastMessageId
    }
    
    public init(userData: NTUserData, messageObj: NTMessage) {
        super.init()
        self.userId = userData.userId
        self.isGroup = userData.isGroup
        self.presence = userData.presence
        self.lastMessageId = userData.lastMessageId
        self.lastMessage = messageObj
    }
    
}
