//
//  NTMessageData+CoreDataClass.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 25/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NTMessageData)
public class NTMessageData: NSManagedObject {
    
    /**
     Saves message in the context
     - parameter messageId: Message Id for user.
     - parameter messageText: text of message
     - parameter messageStatus: current status of message like sent, delivered, read etc.
     - parameter messageType: type of message like text or image.
     - parameter isMine: is message created by me.
     - parameter userId: user id to whom logged in user is chatting. It could be a user or group.
     - parameter createdTimestamp: time at which message is created or received by server.
     - parameter deliveredTimestamp: time at which logged in user's message is delivered to other user or other user's message delivered to logged in user's end.
     - parameter readTimestamp: time at which other user read logged in user's message or logged in user read other user's message
     - parameter receivedTimestamp: time at logged in user receives the message or logged in user received the message from server. It is used to sort message in chat view
     - parameter managedObjectContext: context in which message to be stored.
     - parameter completion: completion block called with saved message
     */
    class func messageForOneToOneChat(messageId: String, messageText: String, messageStatus: MessageStatus, messageType: MessageType, isMine: Bool, userId: String, createdTimestamp: NSNumber, deliveredTimestamp: NSNumber, readTimestamp: NSNumber,receivedTimestamp: NSNumber, managedObjectContext: NSManagedObjectContext ,completion: @escaping (NTMessage?) -> ()) {
        
        self.messageForGroupChat(messageId: messageId, messageText: messageText, messageStatus: messageStatus, messageType: messageType, isMine: isMine, userId: userId, createdTimestamp: createdTimestamp, deliveredTimestamp: deliveredTimestamp, readTimestamp: readTimestamp, receivedTimestamp: receivedTimestamp, managedObjectContext: managedObjectContext, groupId: nil, completion: completion)
        
    }
    
    
    /**
     Saves message in the context
     - parameter messageId: Message Id for user.
     - parameter messageText: text of message
     - parameter messageStatus: current status of message like sent, delivered, read etc.
     - parameter messageType: type of message like text or image.
     - parameter isMine: is message created by me.
     - parameter userId: nil if sent to whole group. If passed then message will be a private message in the group or sender's user id for group message.
     - parameter createdTimestamp: time at which message is created or received by server.
     - parameter deliveredTimestamp: time at which logged in user's message is delivered to other user or other user's message delivered to logged in user's end.
     - parameter readTimestamp: time at which other user read logged in user's message or logged in user read other user's message
     - parameter receivedTimestamp: time at logged in user receives the message or logged in user received the message from server. It is used to sort message in chat view
     - parameter managedObjectContext: context in which message to be stored.
     - parameter groupId: group id to logged in user chatting or receiving message.
     - parameter completion: completion block called with saved message
     */
    
    class func messageForGroupChat(messageId: String, messageText: String, messageStatus: MessageStatus, messageType: MessageType, isMine: Bool, userId: String, createdTimestamp: NSNumber, deliveredTimestamp: NSNumber, readTimestamp: NSNumber, receivedTimestamp: NSNumber, managedObjectContext: NSManagedObjectContext, groupId: String? ,completion: @escaping (NTMessage?) -> ()) {
        
        NTMessageData.message(messageId: messageId, managedObjectContext: managedObjectContext) { (objectId) in
            
            if let _ = objectId{
                completion(nil)
            }else{
                managedObjectContext.perform {
                    let messageData: NTMessageData = managedObjectContext.insertObject()
                    
                    messageData.messageId = messageId
                    messageData.messageText = messageText
                    messageData.messageStatus = messageStatus.nsNumber
                    messageData.messageType = messageType.nsNumber
                    messageData.isMine = NSNumber.init(value: isMine)
                    messageData.createdTimestamp = createdTimestamp
                    messageData.deliveredTimestamp = deliveredTimestamp
                    messageData.readTimestamp = readTimestamp
                    messageData.receivedTimestamp = receivedTimestamp
                    
                    var user: NTUser?
                    var group: NTUser?
                    if let userData = NTUserData.findOrCreate(userId: userId, isGroup: false, managedObjectContext: managedObjectContext){
                        messageData.hasUser = userData
                        if let _ = groupId{
                            
                        }else{
                            userData.lastMessageId = messageData.messageId
                            userData.lastActivityTime = createdTimestamp
                        }
                        
                        user = NTUser.init(userData: userData)
                        
                    }
                    
                    if let gId = groupId, let groupData = NTUserData.findOrCreate(userId: gId, isGroup: true, managedObjectContext: managedObjectContext){
                        messageData.hasGroup = groupData
                    }
                    
                    
                    if let groupData = messageData.hasGroup{
                        groupData.lastMessageId = messageData.messageId
                        groupData.lastActivityTime = createdTimestamp
                        group = NTUser.init(userData: groupData)
                    }
                    
                    var msg: NTMessage?
                    if let userData = user, let groupData = group{
                        msg = NTMessage.init(messageData: messageData, userData: userData, groupData: groupData)
                    }
                    
                    if let userData = user, msg == nil{
                        msg = NTMessage.init(messageData: messageData, userData: userData)
                    }
                    
                    if msg == nil{
                        msg = NTMessage.init(messageData: messageData)
                    }
                    
                    NTDatabaseManager.sharedManager().saveChildContext(context: managedObjectContext, completion: { (success) in
                        if success{
                            completion(msg)
                        }else{
                            completion(nil)
                        }
                    })
                    
                }
            }
        }
    }
    
    
    /**
     Searches message in the context
     - parameter messageId: Message Id to search.
     - parameter managedObjectContext: context in which to search.
     - parameter messageIdFetchCompletion: completion called on finding the message or returns nil.
     */
    class func message(messageId: String, managedObjectContext: NSManagedObjectContext, messageIdFetchCompletion:@escaping (NTMessageData?) -> ()){
        
        managedObjectContext.perform {
            let fetchRequest = NTMessageData.messageFetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate.init(format: "\(messageDataMessageId) == %@", messageId)
            do{
                let result:[NTMessageData]? = try managedObjectContext.fetch(fetchRequest)
                
                if let count = result?.count, count > 0{
                    messageIdFetchCompletion(result?[0])
                }else{
                    messageIdFetchCompletion(nil)
                }
                
            }
            catch{
                print("Error - \(error)")
                messageIdFetchCompletion(nil)
            }
        }
    }
    
    /**
     Searches message in the context
     - parameter messageId: Message Id to search.
     - parameter managedObjectContext: context in which to search.
     - Returns: If found returns message object converted to message model class or nil if not found.
     */
    class func message(messageId: String, managedObjectContext: NSManagedObjectContext) -> NTMessage?{
        
        let fetchRequest = NTMessageData.messageFetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "\(messageDataMessageId) == %@", messageId)
        fetchRequest.fetchLimit = 1
        let primarySortDescriptor = NSSortDescriptor(key: "\(NTMessageData.messageDataCreatedTimeStamp)", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        do{
            let result:[Any]? = try managedObjectContext.fetch(fetchRequest)
            
            if let count = result?.count, count > 0{
                return NTMessage.init(messageData: result![0] as! NTMessageData)
            }else{
                return nil
            }
            
        }
        catch{
            print("Error - \(error)")
            return nil
        }
    }
    
}

extension NTMessageData{
    
    class func markMessageDeliverd(messageId: String, completion:@escaping (NTMessageData?) -> ()){
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        self.message(messageId: messageId, managedObjectContext: childMOC) { (nTMessageData) in
            if let messageData = nTMessageData{
                
                if (messageData.messageStatus?.intValue)! < MessageStatus.delivered.nsNumber.intValue{
                    messageData.messageStatus = MessageStatus.delivered.nsNumber
                    messageData.deliveredTimestamp = NTUtility.getCurrentTime()
                    NTDatabaseManager.sharedManager().saveChildContext(context: childMOC, completion: { (success) in
                        if success{
                            completion(messageData)
                        }
                    })
                }
                
            }
        }
    }
}


extension NTMessageData{
    /**
     Last delivered or received message. Used to get archive messages after this message
     - parameter managedObjectContext: context in which to search.
     - parameter completion: completion called with message or nil if none found.
     */
    class func getLastDeliveredMessage(managedObjectContext: NSManagedObjectContext, completion:@escaping (NTMessageData?) -> ()) {
        managedObjectContext.perform {
            
            let fetchRequest = NTMessageData.messageFetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "\(messageDataMessageStatus) > %@", MessageStatus.sent.nsNumber)
            fetchRequest.fetchLimit = 1
            let primarySortDescriptor = NSSortDescriptor(key: "\(NTMessageData.messageDataCreatedTimeStamp)", ascending: false)
            fetchRequest.sortDescriptors = [primarySortDescriptor]
            do{
                let result:[NTMessageData]? = try managedObjectContext.fetch(fetchRequest)
                
                if let count = result?.count, count > 0{
                    completion(result![0])
                }else{
                    completion(nil)
                }
                
            }
            catch{
                print("Error - \(error)")
                completion(nil)
            }
            
            
        }
    }
    
    class func getAllUnsentMessages(managedObjectContext: NSManagedObjectContext, completion:@escaping ([NTMessageData]?) -> ()) {
        
        managedObjectContext.perform {
            
            let fetchRequest = NTMessageData.messageFetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "\(messageDataMessageStatus) == %@", MessageStatus.waiting.nsNumber)
            let primarySortDescriptor = NSSortDescriptor(key: "\(NTMessageData.messageDataCreatedTimeStamp)", ascending: false)
            fetchRequest.sortDescriptors = [primarySortDescriptor]
            do{
                let result:[NTMessageData]? = try managedObjectContext.fetch(fetchRequest)
                
                if let count = result?.count, count > 0{
                    completion(result)
                }else{
                    completion(nil)
                }
                
            }
            catch{
                print("Error - \(error)")
                completion(nil)
            }
            
        }
    }
    
    
}


extension NTMessageData{
    static let messageDataMessageId = "messageId"
    static let messageDataCreatedTimeStamp = "createdTimestamp"
    static let messageDataDeliveredTimestamp = "deliveredTimestamp"
    static let messageDataIsMine = "isMine"
    static let messageDataMessageStatus = "messageStatus"
    static let messageDataMessageText = "messageText"
    static let messageDataMessageType = "messageType"
    static let messageDataReadTimestamp = "readTimestamp"
    static let messageDataHasUser = "hasUser"
    static let messageDataHasGroup = "hasGroup"
    static let messageDataReceivedTimestamp = "receivedTimestamp"
    
}

extension NTMessageData: ManagedObjectType{
    static var entityName: String  = "NTMessageData"
}

extension NTMessageData{
    public class func messageFetchRequest() -> NSFetchRequest<NTMessageData> {
        return NSFetchRequest<NTMessageData>(entityName: "NTMessageData")
    }
}



