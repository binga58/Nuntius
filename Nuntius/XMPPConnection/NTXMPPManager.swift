//
//  NTXMPPManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit


class NTXMPPManager: NSObject {
    
    static var xmppManager : NTXMPPManager!
    static var xmppConnection : NTXMPPConnection?
    
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

//MARK:-------------- Stream utility callbacks -----------------
extension NTXMPPManager {
    func streamConnected() -> () {
        
    }
    
    func userAuthenticated() -> () {
        
    }
    
}



//MARK:-------------- Errors ---------------
extension NTXMPPManager {
    func xmppStreamError(streamError: NTXMPPStreamError) -> () {
        
    }
}
