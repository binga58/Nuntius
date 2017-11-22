//
//  NTXMPPUtility.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 22/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class NTXMPPUtility: NSObject {
    
    static var account: NTXMPPAccount{
        get{
            return NTXMPPManager.sharedManager().xmppAccount
        }
    }

    //MARK:------------Full UserId--------------
    class func getCurrentUserFullId() -> String
    {
        if let userId = account.userName{
            return getFullId(forFriendId: userId)
        }
        return ""
    }
    
    class func getFullId(forFriendId userId: String) -> String
    {
        if let host = account.serverDomain{
            return userId + "@" + host
        }
        return ""
        
    }
    
}
