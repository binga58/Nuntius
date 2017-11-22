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
    
    func getQueue() -> DispatchQueue{
        return xmppQueue
    }
    
    func connect(){
        NTXMPPManager.xmppConnection?.connect(xmppAccount: xmppAccount)
    }
    
    
}
