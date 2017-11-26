//
//  NTXMPPManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework
//protocol MessageEvents: Class {
////    fun
//}



class NTXMPPManager: NSObject {
    
    static var xmppManager : NTXMPPManager!
    static var xmppConnection : NTXMPPConnection?
    var xmppServerTimeDifference : TimeInterval? = 0
    
    var xmppAccount : NTXMPPAccount!
    let xmppQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
    var retriedCount = 0
    class func sharedManager() -> NTXMPPManager {
        if xmppManager == nil{
            xmppManager = NTXMPPManager()
            xmppConnection = NTXMPPConnection()
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
            let isConnected = NTXMPPManager.xmppConnection?.connect(xmppAccount: xmppAccount)
            if(!isConnected!){
                retriedCount += 1
                self.connect()
            }
        }else if retriedCount == self.xmppAccount.retryCount{
            NTXMPPManager.xmppConnection?.clearXMPPStream()
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
        NTXMPPManager.xmppConnection?.disconnectXMPPStream()
    }
    
}

//MARK:-------------- Send Messages -------------------
extension NTXMPPManager{
    func sendMessage(messageText: String, userId: String){
        if let message = NTXMPPManager.xmppConnection?.sharedMessageManager().createMessage(messageText: messageText, userId: userId){
            NTXMPPManager.xmppConnection?.sendElement(element: message)
        }
    }
    
}

//MARK:--------------- Send presence ---------------------
extension NTXMPPManager{
    func sendPresence(myPresence : MyPresence) -> () {
        if let presence = NTXMPPManager.xmppConnection?.sharedPresenceManager().sendMyPresence(myPresence: myPresence){
            NTXMPPManager.xmppConnection?.sendElement(element: presence)
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
        if let element = NTXMPPManager.xmppConnection?.sharedIQManger().getXMPPServerTime(){
            NTXMPPManager.xmppConnection?.sendElement(element: element)
        }
        
    }
    
    
}
