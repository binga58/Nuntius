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
    
    class func messageForOneToOneChat(messageId: String, messageText: String, messageStatus: MessageStatus, messageType: MessageType, isMine: Bool, userId: String, createdTimestamp: NSNumber, deliveredTimestamp: NSNumber, readTimestamp: NSNumber, managedObjectContext: NSManagedObjectContext ,completion: @escaping (NTMessage?) -> ()) {
        
        self.messageForGroupChat(messageId: messageId, messageText: messageText, messageStatus: messageStatus, messageType: messageType, isMine: isMine, userId: userId, createdTimestamp: createdTimestamp, deliveredTimestamp: deliveredTimestamp, readTimestamp: readTimestamp, managedObjectContext: managedObjectContext, groupId: nil, completion: completion)
        
    }
    
    
    class func messageForGroupChat(messageId: String, messageText: String, messageStatus: MessageStatus, messageType: MessageType, isMine: Bool, userId: String, createdTimestamp: NSNumber, deliveredTimestamp: NSNumber, readTimestamp: NSNumber, managedObjectContext: NSManagedObjectContext, groupId: String? ,completion: @escaping (NTMessage?) -> ()) {
        
        self.message(messageId: messageId, managedObjectContext: managedObjectContext) { (objectId) in
            
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
                    
                    var user: NTUser?
                    var group: NTUser?
                    
                    if let userObjectId: NSManagedObjectID = NTUserData.userIdToObjectId[userId], let userData: NTUserData = managedObjectContext.object(with: userObjectId) as? NTUserData{
                        messageData.hasUser = userData
                        
                        if let _ = groupId{
                            
                        }else{
                            userData.lastMessageId = messageData.messageId
                            userData.lastActivityTime = createdTimestamp
                        }
                        
                        user = NTUser.init(userData: userData)
                    }else{
                        
                        
                        if let userData = NTUserData.userData(For: userId,isGroup: false, managedObjectContext: managedObjectContext){
                            messageData.hasUser = userData
                            if let _ = groupId{
                                
                            }else{
                                userData.lastMessageId = messageData.messageId
                                userData.lastActivityTime = createdTimestamp
                            }
                            
                            user = NTUser.init(userData: userData)
                            
                            
                        }else{
                            
                            if let userData = NTUserData.insertUser(userId: userId, isGroup: false, managedObjectContext: managedObjectContext){
                                messageData.hasUser = userData
                                if let _ = groupId{
                                    
                                }else{
                                    userData.lastMessageId = messageData.messageId
                                    userData.lastActivityTime = createdTimestamp
                                }
                                
                                user = NTUser.init(userData: userData)
                                
                            }
                            
                        }
                        
                    }
                    
                    if let gId = groupId, let groupObjectId: NSManagedObjectID = NTUserData.userIdToObjectId[gId], let groupData: NTUserData = managedObjectContext.object(with: groupObjectId) as? NTUserData{
                        messageData.hasGroup = groupData
                    }else{
                        if let gId = groupId, let groupData = NTUserData.userData(For: gId, isGroup: true, managedObjectContext: managedObjectContext){
                            messageData.hasGroup = groupData
                        }else{
                            
                            if let gId = groupId, let groupData = NTUserData.insertUser(userId: gId, isGroup: true, managedObjectContext: managedObjectContext){
                                messageData.hasGroup = groupData
                            }
                            
                        }
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
                    
                    do{
                        try managedObjectContext.save()
                        completion(msg)
                    }
                    catch{
                        print(error)
                        completion(nil)
                    }
                    
                }
            }
        }
    }
    
    
    class func message(messageId: String, managedObjectContext: NSManagedObjectContext, messageIdFetchCompletion:@escaping (NSManagedObjectID?) -> ()){
        
        managedObjectContext.perform {
            let fetchRequest = NTMessageData.messageFetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate.init(format: "\(messageDataMessageId) == %@", [messageId])
            do{
                let result:[NTMessageData]? = try managedObjectContext.fetch(fetchRequest)
                
                if let count = result?.count, count > 0{
                    messageIdFetchCompletion(result?[0].objectID)
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

}

extension NTMessageData: ManagedObjectType{
    static var entityName: String  = "NTMessageData"
}

extension NTMessageData{
    public class func messageFetchRequest() -> NSFetchRequest<NTMessageData> {
        return NSFetchRequest<NTMessageData>(entityName: "NTMessageData")
    }
}



