//
//  NTXMPPUtility.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 22/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import CoreData

class NTUtility: NSObject {
    
    
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
    
    class func getMessageId() -> String {
        return UUID().uuidString
    }
    
    class func getCurrentTime() -> NSNumber {
        return NSNumber.init(value: Date().timeIntervalSince1970 + NTXMPPManager.sharedManager().xmppServerTimeDifference)
    }
    
    class func getLocalDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }
    
    class func getLocalTimeFromUTC(date:Date) -> String {
        let dateFormatter = self.getLocalDateFormatter()
        let timeStamp = dateFormatter.string(from: date)
        return timeStamp
    }
    
}

extension NSManagedObjectContext {
    func insertObject<A: NSManagedObject & ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription
            .insertNewObject(forEntityName: A.entityName,
                             into: self) as? A else {
                                fatalError("Entity \(A.entityName) does not correspond to \(A.self)")
        }
        return obj
    }
}

protocol ManagedObjectType {
    static var entityName: String { get }
    
}

protocol KeyCodable {
    associatedtype Key: RawRepresentable
}
