//
//  NTXMPPConstants.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 24/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

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
    static let received = "received"
    static let archived = "archived"
    static let readReceipt = "readReceipt"
    static let readMessage = "readMessage"
    static let available = "available"
    static let unavailable = "unavailable"
    static let dnd = "dnd"
    static let away = "away"
    static let xa = "xa"
    static let active = "active"
    static let gone = "gone"
    static let composing = "composing"
    static let paused = "paused"
    static let inactive = "inactive"
    
    struct xmlnsType {
        static let time = "urn:xmpp:time"
        static let receipt = "urn:xmpp:receipts"
        static let mam = "urn:xmpp:mam:1"
        static let jabberXData = "jabber:x:data"
        static let rsm = "http://jabber.org/protocol/rsm"
        static let read = "urn:xmpp:readReceipts"
    }
    
//    struct imageName {
//
//    }
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


enum NTChatState: Int{
    case gone = 0
    case active
    case composing
    case paused
    case inactive
    
    var nsNumber: NSNumber{
        return NSNumber.init(value: self.rawValue)
    }
    
    static func convertChatState(chatState: String) -> NTChatState {
        switch chatState {
        case NTConstants.active:
            return NTChatState.active
        case NTConstants.composing:
            return NTChatState.composing
        case NTConstants.paused:
            return NTChatState.paused
        case NTConstants.inactive:
            return NTChatState.inactive
        case NTConstants.gone:
            return NTChatState.gone
        default:
            return NTChatState.gone
        }
    }
}

enum Presence: Int {
    case online = 1
    case offline
    case away, busy, unavailable
    
    var nsNumber: NSNumber{
        return NSNumber.init(value: self.rawValue)
    }
}

