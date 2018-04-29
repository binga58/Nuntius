//
//  NTMessage.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 25/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class NTMessage: NSObject {
    var msgId: String?
    var messageText: String?
    var isMine: NSNumber?
    var createdTimestamp: NSNumber?
    var deliveredTimestamp: NSNumber?
    var readTimestamp: NSNumber?
    var messageStatus: MessageStatus?
    var messageType: NTMessageType?
    var hasUser: NTUser?
    var hasGroup: NTUser?
    
    
    init(messageData: NTMessageData) {
        super.init()
        self.msgId = messageData.msgId
        self.deliveredTimestamp = messageData.deliveredTimestamp
        self.isMine = messageData.isMine
        self.messageText = messageData.messageText
        self.readTimestamp = messageData.readTimestamp
        self.createdTimestamp = messageData.createdTimestamp
        self.messageStatus = MessageStatus.numberToMessageState(number: messageData.messageStatus)
        self.messageType = NTMessageType.numberToMessageType(number: messageData.messageType)
    }
    
    init(messageData: NTMessageData, userData: NTUser) {
        super.init()
        self.msgId = messageData.msgId
        self.deliveredTimestamp = messageData.deliveredTimestamp
        self.isMine = messageData.isMine
        self.messageText = messageData.messageText
        self.readTimestamp = messageData.readTimestamp
        self.createdTimestamp = messageData.createdTimestamp
        self.messageStatus = MessageStatus.numberToMessageState(number: messageData.messageStatus)
        self.messageType = NTMessageType.numberToMessageType(number: messageData.messageType)
        self.hasUser = userData
    }
    
    init(messageData: NTMessageData, userData: NTUser, groupData: NTUser) {
        super.init()
        self.msgId = messageData.msgId
        self.deliveredTimestamp = messageData.deliveredTimestamp
        self.isMine = messageData.isMine
        self.messageText = messageData.messageText
        self.readTimestamp = messageData.readTimestamp
        self.createdTimestamp = messageData.createdTimestamp
        self.messageStatus = MessageStatus.numberToMessageState(number: messageData.messageStatus)
        self.messageType = NTMessageType.numberToMessageType(number: messageData.messageType)
        self.hasUser = userData
        self.hasGroup = groupData
    }
}
