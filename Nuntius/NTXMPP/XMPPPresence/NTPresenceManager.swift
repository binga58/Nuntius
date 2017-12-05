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
    
    fileprivate var userPresence: [String:Presence] = [:]
    
    /**
     Creates presence node with given presence status
     - parameter myPresence: MyPresence enum value for required presence
     - Returns: XML stanza of presence for xmpp server
     */
    func sendMyPresence(myPresence: Presence) -> DDXMLElement {
        var xmppPresence: XMPPPresence!
        var statusText: String?
        var showText: String?
        switch myPresence
        {
        case .online:
            xmppPresence = XMPPPresence()
            statusText = "Online"
            showText = ""
//        case .unavailable:
//            xmppPresence = XMPPPresence.init(type: "unavailable")
//            statusText = "Offline"
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
        
        if let _ = statusText, let statusNode = DDXMLElement.element(withName: NTConstants.status) as? DDXMLElement{
            statusNode.stringValue = statusText
            xmppPresence.addChild(statusNode)
        }
        
        if let _ = showText, let showNode = DDXMLElement.element(withName: NTConstants.show) as? DDXMLElement{
            showNode.stringValue = showText
            xmppPresence.addChild(showNode)
        }
        
        return xmppPresence
    }
    
    func addUserToRoster(roster: XMPPRoster, user: String, completion: (Bool) -> ()){
//        roster.fetch()
        roster.addUser(XMPPJID.init(string: NTUtility.getFullId(forFriendId: user))!, withNickname: NTUtility.getFullId(forFriendId: user))
        
    }
    
    func updateUserPresence(user: String, presence: Presence) {
        userPresence[user] = presence
        NTXMPPManager.sharedManager().presenceChanged(userId: user, presence: presence)
    }
    
    func getPresence(user: String) -> Presence {
        if let presence = userPresence[user]{
            return presence
        }
        return Presence.offline
    }
    
    
}

//MARK:------------------ XMPPStream presence delegate -------------
extension NTPresenceManager: XMPPStreamDelegate{
    func xmppStream(_ sender: XMPPStream, didFailToSend presence: XMPPPresence, error: Error) {
        
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        if let fromUser = presence.from?.user, fromUser != NTXMPPManager.sharedManager().xmppAccount.userName{
            if presence.type == NTConstants.available{
                var userPresence: Presence = .online
                switch presence.showValue{
                case .away:
                    userPresence = .away
                    
                case .DND:
                    userPresence = .busy
                case .XA:
                    userPresence = .offline
                case .other:
                    userPresence = .online
                case .chat:
                    userPresence = .online
                }
                
                self.updateUserPresence(user: fromUser, presence: userPresence)
                
            }else{
                self.updateUserPresence(user: fromUser, presence: .offline)
            }
        }
        
        
    }
    
    func xmppStream(_ sender: XMPPStream, didSend presence: XMPPPresence) {
        
    }
}

extension NTPresenceManager: XMPPRosterDelegate{
    func xmppRoster(_ sender: XMPPRoster, didReceivePresenceSubscriptionRequest presence: XMPPPresence) {
        
    }
}
