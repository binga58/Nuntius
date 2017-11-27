//
//  NTXMPPManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

class NTXMPPManager: NSObject {
    
    static var xmppManager : NTXMPPManager!
    var xmppConnection : NTXMPPConnection?
    var xmppServerTimeDifference : TimeInterval? = 0
    
    var xmppAccount : NTXMPPAccount!
    let xmppQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
    var retriedCount = 0
    
    public override init() {
        super.init()
        self.xmppConnection = NTXMPPConnection()
    }
    
    class func sharedManager() -> NTXMPPManager {
        if xmppManager == nil{
            xmppManager = NTXMPPManager()
        }
        return xmppManager
    }
    
    
    
    func setxmppAccount(xmppAccount : NTXMPPAccount){
        self.xmppAccount = xmppAccount
    }
    
    /**
     Provides the queue for xmpp related work.
     - Returns: Dispatch queue for xmpp
     */
    func getQueue() -> DispatchQueue{
        return xmppQueue
    }
    
    func connect(){
        if(retriedCount < self.xmppAccount.retryCount){
            let isConnected = NTXMPPManager.sharedManager().xmppConnection?.connect(xmppAccount: xmppAccount)
            if(!isConnected!){
                retriedCount += 1
                self.connect()
            }
        }else if retriedCount == self.xmppAccount.retryCount{
            NTXMPPManager.sharedManager().xmppConnection?.clearXMPPStream()
            retriedCount += 1
            if self.xmppAccount.retryInfiniteTimesOnDisconnection{
                retriedCount = 0
            }
            self.connect()
        }else{
            retriedCount = 0
        }
    }
    
    func disconnect() -> () {
        NTXMPPManager.sharedManager().xmppConnection?.disconnectXMPPStream()
    }
    
}

//MARK:-------------- Send Messages -------------------
extension NTXMPPManager{
    func sendMessage(messageText: String, userId: String){
        
        
        
        
        if let message = NTXMPPManager.sharedManager().xmppConnection?.sharedMessageManager().createMessage(messageText: messageText, userId: userId){
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: message)
        }
    }
    
}

//MARK:--------------- Send presence ---------------------
extension NTXMPPManager{
    func sendPresence(myPresence : MyPresence) -> () {
        if let presence = NTXMPPManager.sharedManager().xmppConnection?.sharedPresenceManager().sendMyPresence(myPresence: myPresence){
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: presence)
        }
        
    }
}



//MARK:-------------- Stream utility callbacks -----------------
extension NTXMPPManager {
    func streamConnected() -> () {
        
    }
    
    func userAuthenticated() -> () {
        self.sendPresence(myPresence: .online)
        self.synchronizeXMPPServerTime()
//        NTXMPPManager.xmppConnection?.sendArchiveRequest(utcDateTime: NSDate())
    }
    
}



//MARK:-------------- Errors ---------------
extension NTXMPPManager {
    func xmppStreamError(streamError: NTStreamError) -> () {
        
    }
}

//MARK:------------- Utility functions ------------
extension NTXMPPManager{
    func synchronizeXMPPServerTime() {
        if let element = NTXMPPManager.sharedManager().xmppConnection?.sharedIQManger().getXMPPServerTime(){
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: element)
        }
    }
}
