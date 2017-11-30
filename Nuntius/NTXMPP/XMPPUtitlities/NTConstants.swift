//
//  NTXMPPConstants.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 24/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

struct NTConstants {
    static let time = "time"
    static let message = "message"
    static let type = "type"
    static let chat = "chat"
    static let id = "id"
    static let to = "to"
    static let from = "from"
    static let body = "body"
    static let request = "request"
    static let xmlns = "xmlns"
    static let show = "show"
    static let status = "status"
    static let utc = "utc"
    static let value = "value"
    static let field = "field"
    static let start = "start"
    static let varXMPP = "var"
    static let query = "query"
    static let queryId = "queryid"
    static let submit = "submit"
    static let hidden = "hidden"
    static let formType = "FORM_TYPE"
    static let x = "x"
    static let max = "max"
    static let set = "set"
    static let result = "result"
    static let forwarded = "forwarded"
    static let delay = "delay"
    static let stamp = "stamp"
    struct xmlnsType {
        static let time = "urn:xmpp:time"
        static let receipt = "urn:xmpp:receipts"
        static let mam = "urn:xmpp:mam:1"
        static let jabberXData = "jabber:x:data"
        static let rsm = "http://jabber.org/protocol/rsm"
    }
}

//func insertObject<A: NSManagedObject>() -> A where A: ManagedObjectType {
//    guard let obj = NSEntityDescription
//        .insertNewObject(forEntityName: A.entityName,
//                         into: self) as? A else {
//                            fatalError("Entity \(A.entityName) does not correspond to \(A.self)")
//    }
//    return obj
//}

protocol EnumToNSNumber {
    var nsNumber: NSNumber{get}
}

enum MessageStatus: Int,EnumToNSNumber {
    
    case failed = -1
    case waiting = 0
    case sent
    case delivered
    case read
    
    var nsNumber: NSNumber{
        return NSNumber.init(value: self.rawValue)
    }
    
    static func numberToMessageState(number:NSNumber?) -> MessageStatus? {
        if let messageStatus = number?.intValue{
            return MessageStatus.init(rawValue: messageStatus)
        }
        return MessageStatus.failed
    }
    
}

enum MessageType: Int, EnumToNSNumber {
    var nsNumber: NSNumber{
        return NSNumber.init(value: self.rawValue)
    }
    
    case text = 0
    
    static func numberToMessageType(number:NSNumber?) -> MessageType? {
        if let messageStatus = number?.intValue{
            return MessageType.init(rawValue: messageStatus)
        }
        return MessageType.text
    }
    
}
