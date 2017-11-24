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
//    static let message = "message"
//    static let type = "type"
//    static let chat = "chat"
//    static let id = "id"
//    static let to = "to"
//    static let from = "from"
//    static let body = "body"
//    static let request = "request"
//    static let xmlns = "xmlns"
//    static let receiptXmlns = "urn:xmpp:receipts"
    
    static let mid = NTUtility.getMessageId()
    
    /**
     Creates message node with body and deleivery recipt request
     - parameter messageText: text message which is to be sent
     - parameter userId: user to which message is meant for
     - Returns: XML stanza of message for xmpp server
     */
    
    class func createMessage(messageText: String?, userId: String?) -> DDXMLElement {
        guard let _ = messageText, let user = userId, user.count > 0 else {
            return DDXMLElement()
        }
        /*
         Example : A content message with receipt requeste look like this
         
         <message xmlns="jabber:client" from="10@54.201.32.5/12612015031454577183303023" to="20@54.201.32.5" type="chat" id="EF96885B-EA00-48CC-810C-8C78045D6B96">
         <body>Awesome</body>
         <request xmlns="urn:xmpp:receipts"/>
         </message>
         */
        guard let messageNode: DDXMLElement = DDXMLElement.element(withName: Constants.message) as? DDXMLElement else{
            return DDXMLElement()
        }
        //Message Node
        let messageId = NTUtility.getMessageId()
        messageNode.addAttribute(withName: Constants.type, stringValue: Constants.chat)
        messageNode.addAttribute(withName: Constants.to, stringValue: NTUtility.getFullId(forFriendId: userId!))
        messageNode.addAttribute(withName: Constants.id, stringValue: messageId)
        messageNode.addAttribute(withName: Constants.from, stringValue: NTUtility.getCurrentUserFullId())
        
        //Body node
        guard let bodyNode: DDXMLElement = DDXMLElement.element(withName: Constants.body) as? DDXMLElement else {
            return DDXMLElement()
        }
        
        bodyNode.stringValue = messageText
        
        //Request node for receipt
        guard let receiptNode: DDXMLElement = DDXMLElement.element(withName: Constants.request) as? DDXMLElement else{
            return DDXMLElement()
        }
        
        receiptNode.addAttribute(withName: Constants.xmlns, stringValue: Constants.xmlnsType.receipt)
        receiptNode.addAttribute(withName: Constants.id, stringValue: mid)
        
        //Add body and receipt to message node
        messageNode.addChild(bodyNode)
        messageNode.addChild(receiptNode)
        
        return messageNode
        
    }
    
//    class func sendMessage(messageText: String, groupId: String, privateUserId: String) -> DDXMLElement{
//
//
//    }
    
    func messageReceived(message: XMPPMessage){
        
    }
    
    
}


extension NTMessageManager{
    class func sendMAMRequest() {
        
    }
    
}
