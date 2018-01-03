//
//  NTUserData+CoreDataClass.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 27/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NTUserData)
public class NTUserData: NSManagedObject {
    
    /**
     Checks if user enters in database
     - parameter userId: user id for userdata to search.
     - parameter isGroup: single user or group user.
     - parameter managedObjectContext: context in which to search.
     - Returns: If found returns userdata else returns nil.
     */
    class func userData(For userId:String, isGroup: Bool, managedObjectContext: NSManagedObjectContext) -> NTUserData?{
        
        let fetchRequest = NTUserData.userFetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "\(userDataIsGroup) == %@ && \(userDataUserId) == %@", NSNumber.init(value: isGroup),userId)
        fetchRequest.fetchLimit = 1
        do{
            let result: [NTUserData] = try managedObjectContext.fetch(fetchRequest)
            if result.count > 0{
                return result[0]
            }
        }
        catch{
            print(error)
            return nil
        }
        return nil
    }
    
    /**
     Checks if user enters in database
     - parameter userId: user id for userdata to search.
     - parameter isGroup: single user or group user.
     - parameter managedObjectContext: context in which to search.
     - parameter: completion block with fetched data
     */
    class func userData(For userId:String, isGroup: Bool, managedObjectContext: NSManagedObjectContext, completion:@escaping (NTUserData?) -> Void) -> Void{
        
        managedObjectContext.perform {
            let fetchRequest = NTUserData.userFetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "\(userDataIsGroup) == %@ && \(userDataUserId) == %@", NSNumber.init(value: isGroup),userId)
            fetchRequest.fetchLimit = 1
            do{
                let result: [NTUserData] = try managedObjectContext.fetch(fetchRequest)
                if result.count > 0{
                    return completion(result[0])
                }
            }
            catch{
                print(error)
                completion(nil)
            }
        }
    }
    
    
    /**
     Find or create user in context.
     - parameter userId: user id for userdata.
     - parameter isGroup: single user or group user.
     - parameter managedObjectContext: context in which to inisert.
     - parameter completion: completion block to call when user data stores in context
     */
    class func insertUserOnBackground(userId: String, isGroup: Bool, managedObjectContext: NSManagedObjectContext, completion: @escaping (NTUser?) -> ()) {
        managedObjectContext.perform {
            if let user = self.userData(For: userId, isGroup: isGroup, managedObjectContext: managedObjectContext){
                completion(NTUser.init(ntUserData: user))
            }
            
            let userData: NTUserData = managedObjectContext.insertObject()
            userData.userId = userId
            userData.isGroup = NSNumber.init(value: isGroup)
            
            let user = NTUser.init(ntUserData: userData)
            NTDatabaseManager.sharedManager().saveChildContext(context: managedObjectContext, completion: { (success) in
                if success{
                    completion(user)
                    NTDatabaseManager.sharedManager().saveToPersistentStore()
                }
            })
        }
    }
    
    
    /**
     Find or create user in context.
     - parameter userId: user id for userdata.
     - parameter isGroup: single user or group user.
     - parameter managedObjectContext: context in which to insert.
     - parameter managedObjectContext: context in which to insert.
     - Returns: user data created in context. USER IS NOT SAVED HERE.
     */
    class func findOrCreate(userId: String, isGroup: Bool, managedObjectContext: NSManagedObjectContext) -> NTUserData? {
        if let user = self.userData(For: userId, isGroup: isGroup, managedObjectContext: managedObjectContext){
            return user
        }
        
        let userData: NTUserData = managedObjectContext.insertObject()
        userData.userId = userId
        userData.isGroup = NSNumber.init(value: isGroup)
        
        let userObjectId = userData.objectID
        
        do{
            if let _: NTUserData = managedObjectContext.object(with: userObjectId) as? NTUserData{
                
                return userData
            }
        }
        return nil
    }
    
    /*
     Marks all users to offline and saves it to database.
    */
    
    class func markAllUsersUnavailableAndSaveToPersistentStore() -> Void {
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        childMOC.perform {
            let fetchRequest = NTUserData.userFetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "\(userDataIsGroup) == %@", NSNumber.init(value: false))
            fetchRequest.fetchLimit = 1
            do{
                let result: [NTUserData] = try childMOC.fetch(fetchRequest)
                for userData in result{
                    userData.chatState = ChatState.inactive.nsNumber
                    userData.presence = Presence.offline.nsNumber
                }
                
            }
            catch{
                print(error)
            }
            
            NTDatabaseManager.sharedManager().saveChildContext(context: childMOC, completion: { (_) in
                NTDatabaseManager.sharedManager().saveToPersistentStore()
            })
            
        }
        
        
        
    }
    
    
    
    
    
}

extension NTUserData{
    public class func userFetchRequest() -> NSFetchRequest<NTUserData> {
        return NSFetchRequest<NTUserData>(entityName: "NTUserData")
    }
    
    static let userDataLastMessageId = "lastMessageId"
    static let userDataPresence = "presence"
    static let userDataLastActivityTime = "lastActivityTime"
    static let userDataHasGroupMessages = "hasGroupMessages"
    static let userDataHasMessages = "hasMessages"
    static let userDataUserId = "userId"
    static let userDataIsGroup = "isGroup"
    static let userDataChatState = "chatState"
}

extension NTUserData: ManagedObjectType{
    static var entityName: String = "NTUserData"
}
