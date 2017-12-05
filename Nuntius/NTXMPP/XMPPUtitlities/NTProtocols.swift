//
//  NTProtocols.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 05/12/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

protocol PresenceChanged: class {
    func presenceChanged(user:String, presence: Presence)
}

protocol MessagingEvents {
    func messageSent(messageData: NTMessageData?)
    
    func messageDelivered(messageData: NTMessageData?)
    
    func messageRead(messageData: NTMessageData?)
    
    func messageReceived(messageData: NTMessageData?)
}

protocol ConnectionEvents {
    func xmppConnected()
    
    func xmppAuthenticated()
    
    func xmppDisconnected()
    
    func xmppConnectionError(error: NTStreamError)
}

