//
//  NTXMPPChatManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 22/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

class NTXMPPChatManager: NSObject {
    static let message = "message"
    static let type = "type"
    static let chat = "chat"
    static let id = "id"
    static let to = "to"
    static let from = "from"
    static let body = "body"
    static let request = "request"
    static let xmlns = "xmlns"
    static let receiptXmlns = "urn:xmpp:receipts"
    class func sendMessage(messageText: String, userId: String) -> DDXMLElement {
        if let messageNode: DDXMLElement = DDXMLElement.element(withName: message) as? DDXMLElement{
            messageNode.addAttribute(withName: type, stringValue: chat)
        }
        
        return DDXMLElement()
        
    }
    
//    class func sendMessage(messageText: String, groupId: String, privateUserId: String) -> DDXMLElement{
//
//
//    }
    
}
