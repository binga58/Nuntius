//
//  NTXMPPAccount.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class NTXMPPAccount: NSObject {
    var serverDomain : String?
    var userName : String?
    var password : String?
    var groupChatServiceName: String?
    var port : UInt16! = 5222
    var retryCount = 5
    var retryInfiniteTimesOnDisconnection = false
    var timeoutInterval : Double! = 10.0
    var allowSelfSignedCertificates : Bool! = false
    var allowSSLHostNameMismatch: Bool! = false
    var mamPaginationCount: Int = 10000
    var checkMAM: Bool = false
    var presence: Presence = .online
    
    /**
     Creates account object consisting of basic xmpp details
     - parameter serverDomain: domain of xmpp server
     - parameter userName: username or user Id without domain and resource
     - parameter password: password of user for authentication
     - parameter groupChatServiceName: group service name for group messaging. If project does not support group messaging then pass empty string
     */
    
    init(serverDomain : String, userName : String, password : String, groupChatServiceName: String){
        super.init()
        self.serverDomain = serverDomain
        self.userName = userName
        self.password = password
        self.groupChatServiceName = groupChatServiceName
    }
    
    
    
}
