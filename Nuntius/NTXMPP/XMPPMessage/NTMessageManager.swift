//
//  NTXMPPChatManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 22/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

class NTMessageManager: NSObject {
    
    fileprivate static var requestingArrayCount = [String]()
    
    fileprivate static var globalMAMCount = 0
    
    fileprivate var outstandingXMPPStanzaResponseBlocks:[String: (String) -> ()] = [:]
    
    
    //MARK:-------------- Create message related stanzas -------
    /**
     Creates message node with body and deleivery recipt request
     - parameter messageText: text message which is to be sent
     - parameter userId: user to which message is meant for
     - Returns: XML stanza of message for xmpp server
     */
    
    func createMessage(messageText: String?, userId: String?, messageId: String?) -> DDXMLElement {
        guard let _ = messageText, let user = userId, user.count > 0, let msgId = messageId else {
            return DDXMLElement()
        }
        /*
         Example : A content message with receipt requeste look like this
         
         <message xmlns="jabber:client" from="10@54.201.32.5/12612015031454577183303023" to="20@54.201.32.5" type="chat" id="EF96885B-EA00-48CC-810C-8C78045D6B96">
         <body>Awesome</body>
         <request xmlns="urn:xmpp:receipts"/>
         </message>
         */
        guard let messageNode: DDXMLElement = DDXMLElement.element(withName: NTConstants.message) as? DDXMLElement else{
            return DDXMLElement()
        }
        //Message Node
//        let messageId = NTUtility.getMessageId()
        messageNode.addAttribute(withName: NTConstants.type, stringValue: NTConstants.chat)
        messageNode.addAttribute(withName: NTConstants.to, stringValue: NTUtility.getFullId(forFriendId: userId!))
        messageNode.addAttribute(withName: NTConstants.id, stringValue: msgId)
        messageNode.addAttribute(withName: NTConstants.from, stringValue: NTUtility.getCurrentUserFullId())
        
        //Body node
        guard let bodyNode: DDXMLElement = DDXMLElement.element(withName: NTConstants.body) as? DDXMLElement else {
            return DDXMLElement()
        }
        
        bodyNode.stringValue = messageText
        
        //Request node for receipt
        guard let receiptNode: DDXMLElement = DDXMLElement.element(withName: NTConstants.request) as? DDXMLElement else{
            return DDXMLElement()
        }
        
        receiptNode.addAttribute(withName: NTConstants.xmlns, stringValue: NTConstants.xmlnsType.receipt)
        receiptNode.addAttribute(withName: NTConstants.id, stringValue: msgId)
        
        //Add body and receipt to message node
        messageNode.addChild(bodyNode)
        messageNode.addChild(receiptNode)
        
        return messageNode
        
    }
    
    func createChatStateStanza(userId: String, chatState: ChatState) -> DDXMLElement {
        guard let messageNode: DDXMLElement = DDXMLElement.element(withName: NTConstants.message) as? DDXMLElement else{
            return DDXMLElement()
        }
        messageNode.addAttribute(withName: NTConstants.type, stringValue: NTConstants.chat)
        messageNode.addAttribute(withName: NTConstants.to, stringValue: NTUtility.getFullId(forFriendId: userId))
        messageNode.addAttribute(withName: NTConstants.id, stringValue: NTUtility.getMessageId())
        messageNode.addAttribute(withName: NTConstants.from, stringValue: NTUtility.getCurrentUserFullId())
        
        
        let xmppMessage = XMPPMessage.init(from: messageNode)
        switch chatState {
        case .active:
            xmppMessage.addActiveChatState()
        case .composing:
            xmppMessage.addComposingChatState()
        case .gone:
            xmppMessage.addGoneChatState()
        case .inactive:
            xmppMessage.addInactiveChatState()
        case .paused:
            xmppMessage.addPausedChatState()
        }
        
        return messageNode
    }
    
    
    //MARK:-------------------- Read receipts send/receive -----------------
    func sendReadReceiptToUserForOneToOneChat(user: NTUserData?, completion:@escaping (Bool) -> ()) {
        guard let messageNode: DDXMLElement = DDXMLElement.element(withName: NTConstants.message) as? DDXMLElement else{
            return
        }
        
        let messageId = NTUtility.getMessageId()
        messageNode.addAttribute(withName: NTConstants.type, stringValue: NTConstants.chat)
        messageNode.addAttribute(withName: NTConstants.to, stringValue: NTUtility.getFullId(forFriendId: (user?.userId)!))
        messageNode.addAttribute(withName: NTConstants.id, stringValue: messageId)
        messageNode.addAttribute(withName: NTConstants.from, stringValue: NTUtility.getCurrentUserFullId())
        
        let readNode = DDXMLElement.init(name: NTConstants.readReceipt, xmlns: NTConstants.xmlnsType.read)
        
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        NTMessageData.getMessagesWithUnsentReadReceiptsOneToOneChat(context: childMOC, userData: user) { (messageList) in
            if let list = messageList{
                
                for message in list{
                    if let readMessage: DDXMLElement = DDXMLElement.element(withName: NTConstants.readMessage) as? DDXMLElement{
                        readMessage.addAttribute(withName: NTConstants.id, stringValue: message.messageId!)
                        readMessage.addAttribute(withName: NTConstants.time, doubleValue: floor(((message.readTimestamp?.doubleValue)! * 1000)))
                        readNode.addChild(readMessage)
                    }
                    
                }
                
                
                
                self.outstandingXMPPStanzaResponseBlocks[messageId] = {(stanzaId: String) in
                    
                    if stanzaId == messageId{
                        
                        for message in list{
                            message.messageStatus = MessageStatus.read.nsNumber
                        }
                        NTDatabaseManager.sharedManager().saveChildContext(context: childMOC, completion: { (success) in
                            
                        })
                        completion(true)
                    }
                    
                }
                
                messageNode.addChild(readNode)
                
                NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: messageNode)
                
                
                
            }
        }
        
    }
    
    func receiveReadReceipts(message: XMPPMessage) -> () {
        if let readRecipt = message.element(forName: NTConstants.readReceipt), let readMessaged = readRecipt.children{
            for messageNode in readMessaged{
                if let node: DDXMLElement = messageNode as? DDXMLElement, let messageId: String = node.attributeStringValue(forName: NTConstants.id), node.attributeDoubleValue(forName: NTConstants.time) > 0 {
                    let time = (node.attributeDoubleValue(forName: NTConstants.time) / 1000)
                    let childMOC = NTDatabaseManager.sharedManager().getChildContext()
                    NTMessageData.message(messageId: messageId, managedObjectContext: childMOC, messageIdFetchCompletion: { (nTMessageData) in
                        if let messageData = nTMessageData, messageData.messageStatus?.intValue == MessageStatus.delivered.rawValue, messageData.readTimestamp?.doubleValue == 0{
                            messageData.messageStatus = MessageStatus.read.nsNumber
                            if time > NTUtility.getCurrentTime().doubleValue{
                                messageData.readTimestamp = NTUtility.getCurrentTime()
                            }else{
                                messageData.readTimestamp = NSNumber.init(value: time)
                            }
                            NTDatabaseManager.sharedManager().saveChildContext(context: childMOC, completion: { (success) in
                                
                            })
                            
                        }
                    })
                    
                }
            }
            
            NTDatabaseManager.sharedManager().saveToPersistentStore()
        }
        
        
    }
    
    
    //MARK:------------------- Messages with body------------------
    func messageReceived(message: XMPPMessage){
        
        if let messageId = message.elementID as NSString?, let _ = message.element(forName: NTConstants.body), let userId = message.from?.user{
            
            var text: String
            if let messageText = message.element(forName: NTConstants.body)?.stringValue{
                text = messageText
            }else{
                text = ""
            }
            var createdTimestamp: NSNumber!
            if let archived = message.element(forName: NTConstants.archived), let time = archived.attribute(forName: NTConstants.id)?.stringValue{
                
                createdTimestamp = NSNumber.init(value: (Double(time)! / 1000000))
            }else{
                createdTimestamp = NTUtility.getCurrentTime()
            }
            
            let childMOC = NTDatabaseManager.sharedManager().getChildContext()
            
            NTMessageData.messageForOneToOneChat(messageId: messageId as String, messageText: text, messageStatus: .delivered, messageType: .text, isMine: false, userId: userId, createdTimestamp: createdTimestamp, deliveredTimestamp: NTUtility.getCurrentTime(), readTimestamp: NSNumber.init(value: 0), receivedTimestamp: NTUtility.getCurrentTime(), managedObjectContext: childMOC, completion: { (savedMessage) in
                
                if let _ = savedMessage{
                    NTDatabaseManager.sharedManager().saveToPersistentStore()
                    self.sendDeliveryReceipt(message: message)
                }
            })
            
            
        }
        
    }
    
    
    func archiveMessage(message: XMPPMessage, delay: XMLElement){
        if let messageId = message.elementID as NSString?, let _ = message.element(forName: NTConstants.body), let fromUserId = message.from?.user, let toUserId = message.to?.user,  let dateString = delay.attribute(forName: NTConstants.stamp)?.stringValue, let date: NSDate = NSDate.init(xmppDateTime: dateString){
            
            let createdTime = NTUtility.getLocalTimeFromUTC(date: date as Date)
            let receivedTime = NTUtility.getCurrentTime()
            print(createdTime)
            print(receivedTime)
            
            let createdTimestamp = NSNumber.init(value: date.timeIntervalSince1970)
            let receivedTimestamp = NTUtility.getCurrentTime()
            
            let userId = fromUserId == NTXMPPManager.sharedManager().xmppAccount.userName ? toUserId : fromUserId
            
            var text: String
            if let messageText = message.element(forName: NTConstants.body)?.stringValue{
                text = messageText
            }else{
                text = ""
            }
            
            let childMOC = NTDatabaseManager.sharedManager().getChildContext()
            
            let isMine: Bool = fromUserId == NTXMPPManager.sharedManager().xmppAccount.userName! ? true : false
            
            
            NTMessageData.messageForOneToOneChat(messageId: messageId as String, messageText: text, messageStatus: .delivered, messageType: .text, isMine: isMine, userId: userId, createdTimestamp: createdTimestamp, deliveredTimestamp: NTUtility.getCurrentTime(), readTimestamp: NSNumber.init(value: 0), receivedTimestamp: receivedTimestamp, managedObjectContext: childMOC, completion: { (savedMessage) in
                
                if let _ = savedMessage{
                    if NTMessageManager.globalMAMCount == NTXMPPManager.sharedManager().xmppAccount.mamPaginationCount{
                        NTDatabaseManager.sharedManager().saveToPersistentStore()
                        NTMessageManager.globalMAMCount = 0
                    }else{
                        NTMessageManager.globalMAMCount += 1
                    }
                    
                    //Send Delivery receipt
                    self.sendDeliveryReceipt(message: message)
                }
            })
        }
    }
    
    //MARK:-------------------- Mark message sent -----------------
    func markMessageSent(message: String?) {
        if let messageId: String = message{
            
            let childMOC = NTDatabaseManager.sharedManager().getChildContext()
            
            
                NTMessageData.message(messageId: messageId as String, managedObjectContext: childMOC, messageIdFetchCompletion: { (nTMessageData) in
                    if let messageData = nTMessageData{
                        childMOC.perform {
                            
                            if (messageData.messageStatus?.intValue)! < MessageStatus.sent.rawValue{
                               messageData.messageStatus = MessageStatus.sent.nsNumber
                                NTDatabaseManager.sharedManager().saveChildContext(context: childMOC, completion: { (success) in
                                    if success{
                                        NTDatabaseManager.sharedManager().saveToPersistentStore()
                                    }
                                })
                            }
                            
                        }
                    }
                })
        }
        
        
    }
    
    //MARK:----------------- Mark/Send messages delivered at other end --------
    
    /**
     Marks the message delivered in database
     */
    func markMessageDelivered(messageElement: XMPPMessage?){
        if let message: DDXMLElement = messageElement, let receivedNode: DDXMLElement = message.element(forName: NTConstants.received), let messageId = receivedNode.attribute(forName: NTConstants.id)?.stringValue{
            NTMessageData.markMessageDeliverd(messageId: messageId, completion: { (messageData) in
                NTDatabaseManager.sharedManager().saveToPersistentStore()
            })
        }
    }
    
    
    
    /**
     Sends delivery receipt of received message
     */
    func sendDeliveryReceipt(message: XMPPMessage) {
        if let deliveryReceipt = message.generateReceiptResponse{
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: deliveryReceipt)
        }
        
    }
    
    
    
}

//MARK:------------------ XMPPStream Message delegate -------------
extension NTMessageManager: XMPPStreamDelegate{
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        
        if let _ = message.element(forName: NTConstants.received){
            return
        }
        
        if let msgId = message.elementID, let _ = message.element(forName: NTConstants.body){
            self.outstandingXMPPStanzaResponseBlocks[msgId] = {(stanzaId: String) in
                
                if stanzaId == msgId{
                    
                    self.markMessageSent(message: msgId)
                    
                }
                
            }
        }
        
        
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        if let _ = message.element(forName: NTConstants.body){
            self.messageReceived(message: message)
            return
        }
        if let _ = message.element(forName: NTConstants.readReceipt){
            self.receiveReadReceipts(message: message)
            return
        }
    }
    
    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        
    }
}

//MARK:------------------ Message Delivery receipts ------------
extension NTMessageManager: XMPPMessageDeliveryReceiptsDelegate{
    func xmppMessageDeliveryReceipts(_ xmppMessageDeliveryReceipts: XMPPMessageDeliveryReceipts, didReceiveReceiptResponseMessage message: XMPPMessage) {
        self.markMessageDelivered(messageElement: message)
    }
}

//MARK:----------------- IQ result completion --------------
extension NTMessageManager{
    /**
     Perform completion block on completion of iq query
     */
    func callAndRemoveOutstandingBlock(messageId: String){
        
        if let block = outstandingXMPPStanzaResponseBlocks[messageId]{
            block(messageId)
            outstandingXMPPStanzaResponseBlocks.removeValue(forKey: messageId)
        }
        
    }
}


//MARK:------------------ Archive message delegate -------------
extension NTMessageManager : XMPPMessageArchiveManagementDelegate{
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveMAMMessage message: XMPPMessage) {
        if let result = message.element(forName: NTConstants.result), let forwarded = result.element(forName: NTConstants.forwarded), let msg = forwarded.element(forName: NTConstants.message), let _ = msg.element(forName: NTConstants.body), let delay = forwarded.element(forName: NTConstants.delay){
            self.archiveMessage(message: XMPPMessage.init(from: msg), delay: delay)
        }
    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFailToReceiveMessages error: XMPPIQ) {
        
    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFinishReceivingMessagesWith resultSet: XMPPResultSet) {
        
    }
    
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveFormFields iq: XMPPIQ) {
        
    }
}

//MARK:---------------- Stream management delegate ----------
extension NTMessageManager: XMPPStreamManagementDelegate{
    func xmppStreamManagement(_ sender: XMPPStreamManagement, didReceiveAckForStanzaIds stanzaIds: [Any]) {
        for stanzaId in stanzaIds{
            if let messageId: String = stanzaId as? String{
                self.callAndRemoveOutstandingBlock(messageId: messageId)
            }
        }
    }
    
    func xmppStreamManagement(_ sender: XMPPStreamManagement, getIsHandled isHandledPtr: UnsafeMutablePointer<ObjCBool>?, stanzaId stanzaIdPtr: AutoreleasingUnsafeMutablePointer<AnyObject?>?, forReceivedElement element: XMPPElement) {
        
    }
}




