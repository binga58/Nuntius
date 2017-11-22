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
    var port : UInt16! = 5222
    var retryCount = 5
    var retryInfiniteTimesOnDisconnection = false
    var timeoutInterval : Double! = 10.0
    var allowSelfSignedCertificates : Bool! = false
    var allowSSLHostNameMismatch: Bool! = false
    
    init(serverDomain : String, userName : String, password : String){
        super.init()
        self.serverDomain = serverDomain
        self.userName = userName
        self.password = password
    }
    
    
    
}
