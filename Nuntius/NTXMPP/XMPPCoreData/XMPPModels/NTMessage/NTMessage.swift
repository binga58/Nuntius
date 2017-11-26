//
//  NTMessage.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 25/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class NTMessage: NSObject {
    var messageId: String?
    var deliveredTimestamp: NSNumber?
    var isMine: NSNumber?
    var messageText: String?
    var readTimestamp: NSNumber?
    var createdTimestamp: NSNumber?
    
    init(messageData: NTMessageData) {
        super.init()
        self.messageId = messageData.messageId
        self.deliveredTimestamp = messageData.deliveredTimestamp
        self.isMine = messageData.isMine
        self.messageText = messageData.messageText
        self.readTimestamp = messageData.readTimestamp
        self.createdTimestamp = messageData.createdTimestamp
    }
}
