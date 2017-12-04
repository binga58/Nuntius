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
    var operationQueue: OperationQueue = {
        var tempOperationQueue = OperationQueue.init()
        return tempOperationQueue
    }()
    var xmppServerTimeDifference : TimeInterval = 0
    
    var xmppAccount : NTXMPPAccount!
    let xmppQueue = DispatchQueue(label: "xmppQueue", attributes: .concurrent)
    var retriedCount = 0
    
    public override init() {
        super.init()
        self.xmppConnection = NTXMPPConnection()
        addObservers()
    }
    
    deinit {
        removeObservers()
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
        let messageId = NTUtility.getMessageId()
        
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        
        NTMessageData.messageForOneToOneChat(messageId: messageId, messageText: messageText, messageStatus: .waiting, messageType: .text, isMine: true, userId: userId, createdTimestamp: NTUtility.getCurrentTime(), deliveredTimestamp: NSNumber.init(value: 0), readTimestamp: NSNumber.init(value: 0), receivedTimestamp: NTUtility.getCurrentTime(), managedObjectContext: childMOC) { (messageObj) in
            
            if let msg = messageObj{
                NTDatabaseManager.sharedManager().saveToPersistentStore()
                self.operationQueue.addOperation {
                    if let message = NTXMPPManager.sharedManager().xmppConnection?.sharedMessageManager().createMessage(messageText: msg.messageText, userId: msg.hasUser?.userId, messageId: messageId){
                        NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: message)
                    }
                }
            }
        }
    }
    
    /**
     Fetches messages with message state .waiting and sent them.
     */
    func sendAllUnsentMessages() {
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        NTMessageData.getAllUnsentMessages(managedObjectContext: childMOC) { (messageDataList) in
            if let list = messageDataList{
                for msg in list{
                    self.operationQueue.addOperation {
                        if let message = NTXMPPManager.sharedManager().xmppConnection?.sharedMessageManager().createMessage(messageText: msg.messageText, userId: msg.hasUser?.userId, messageId: msg.messageId!){
                            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: message)
                        }
                    }
                    
                }
                
                
            }
        }
        
    }

    
}


//MARK:--------------- Mark messages read ----------------
extension NTXMPPManager{
    func markMessagesRead(userData: NTUserData?, completion:@escaping (Bool) -> ()) {
        if let user = userData{
            let childMOC = NTDatabaseManager.sharedManager().getChildContext()
            NTMessageData.getAllUnreadMessagesForOneToOneChat(context: childMOC, userData: user) { (messageDataList) in
                if let messages = messageDataList{
                    for message in messages{
                        message.readTimestamp = NTUtility.getCurrentTime()
                    }
                }
                NTDatabaseManager.sharedManager().saveChildContext(context: childMOC, completion: { (success) in
                    if success{
                        completion(true)
                    }
                })
            }
            
        }
    }
    
    func sendReadReceiptsToUser(user: NTUserData?, completion:@escaping (Bool) -> ()) {
        NTXMPPManager.sharedManager().xmppConnection?.sharedMessageManager().sendReadReceiptToUserForOneToOneChat(user: user, completion: { (success) in
            completion(success)
        })
    }
}


//MARK:--------------- Send Chat state to user -----------
extension NTXMPPManager{
    func sendChatStateToUser(userId: String){
        if let element = NTXMPPManager.sharedManager().xmppConnection?.sharedMessageManager().createChatStateStanza(userId: userId, chatState: .active){
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: element)
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
    
    func addInRoster(userId: String?) -> Void {
        if let user: String = userId{
            
            self.xmppConnection?.addUserToRoster(userId: user)
        }
        
    }
}



//MARK:-------------- Stream utility callbacks -----------------
extension NTXMPPManager {
    func streamConnected() -> () {
        
    }
    
    func userAuthenticated() -> () {
        
        self.synchronizeXMPPServerTime { (success) in
            if success{
                
                if NTXMPPManager.sharedManager().xmppAccount.checkMAM {
                    
                    NTXMPPManager.sharedManager().checkForMAM()
                    
                }else{
                    
                    self.sendPresence(myPresence: .online)
                    
                }
                
                self.afterAuthenticationProcesses()
                
            }
            
        }
        
    }
    
}



//MARK:-------------- Errors ---------------
extension NTXMPPManager {
    func xmppStreamError(streamError: NTStreamError) -> () {
        
    }
}

//MARK:------------- Utility functions ------------
extension NTXMPPManager{
    func synchronizeXMPPServerTime(completion:@escaping (Bool) -> ()) {
        if let element = NTXMPPManager.sharedManager().xmppConnection?.sharedIQManger().getXMPPServerTime(completion: completion){
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: element)
        }
    }
    
    func checkForMAM() {
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        NTMessageData.getLastDeliveredMessage(managedObjectContext: childMOC){ (nTMessageData) in
            if let messageData = nTMessageData, let timeInterval = messageData.deliveredTimestamp?.doubleValue{
                let time = Date.init(timeIntervalSince1970: timeInterval - self.xmppServerTimeDifference)
                
                //                        let time = Date.init(timeIntervalSince1970: 0)
                NTXMPPManager.sharedManager().xmppConnection?.sendArchiveRequest(utcDateTime: time as NSDate)
            }
            
            self.sendPresence(myPresence: .online)
        }
        
    }
    
    func afterAuthenticationProcesses() {
        self.sendAllUnsentMessages()
        
    }
}


//MARK:------------- App Background/Termination notification -------------
extension NTXMPPManager{
    private func addObservers() {
        do{
            NotificationCenter.default.addObserver(self, selector: #selector(appInBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appInTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appInForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            
        }
    }
    
    private func removeObservers() {
        do{
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func appInForeground() -> Void {
        
    }
    
    @objc private func appInBackground(){
        NTDatabaseManager.sharedManager().saveToPersistentStore()
        self.disconnect()
    }
    
    @objc func appInTerminate() {
        NTDatabaseManager.sharedManager().saveToPersistentStore()
        self.disconnect()
        self.xmppConnection?.clearXMPPStream()
    }
    
}

