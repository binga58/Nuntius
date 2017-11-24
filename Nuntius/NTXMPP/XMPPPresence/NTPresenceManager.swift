//
//  NTXMPPPresenceManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

class NTPresenceManager: NSObject {
    
    /**
     Creates presence node with given presence status
     - parameter myPresence: MyPresence enum value for required presence
     - Returns: XML stanza of presence for xmpp server
     */
    class func sendMyPresence(myPresence: MyPresence) -> DDXMLElement {
        var xmppPresence: XMPPPresence!
        var statusText: String?
        var showText: String?
        switch myPresence
        {
        case .online:
            xmppPresence = XMPPPresence()
            statusText = "Online"
            showText = ""
        case .unavailable:
            xmppPresence = XMPPPresence.init(type: "unavailable")
            statusText = "Offline"
        case .offline:
            xmppPresence = XMPPPresence()
            statusText = "Offline"
            showText = "xa"
        case .away:
            xmppPresence = XMPPPresence()
            statusText = "Away"
            showText = "away"
        case .busy:
            xmppPresence = XMPPPresence()
            statusText = "Busy"
            showText = "dnd"
        }
        
        if let _ = statusText, let statusNode = DDXMLElement.element(withName: Constants.status) as? DDXMLElement{
            statusNode.stringValue = statusText
            xmppPresence.addChild(statusNode)
        }
        
        if let _ = showText, let showNode = DDXMLElement.element(withName: Constants.show) as? DDXMLElement{
            showNode.stringValue = showText
            xmppPresence.addChild(showNode)
        }
        
        return xmppPresence
    }
    
    
}
