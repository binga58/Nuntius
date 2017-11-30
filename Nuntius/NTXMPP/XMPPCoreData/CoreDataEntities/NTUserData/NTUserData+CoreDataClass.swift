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
     Find or create user in context.
     - parameter userId: user id for userdata.
     - parameter isGroup: single user or group user.
     - parameter managedObjectContext: context in which to inisert.
     - parameter completion: completion block to call when user data stores in context
     */
    class func insertUserOnBackground(userId: String, isGroup: Bool, managedObjectContext: NSManagedObjectContext, completion: @escaping (NTUser?) -> ()) {
        managedObjectContext.perform {
            if let user = self.userData(For: userId, isGroup: isGroup, managedObjectContext: managedObjectContext){
                completion(NTUser.init(userData: user))
            }
            
            let userData: NTUserData = managedObjectContext.insertObject()
            userData.userId = userId
            userData.isGroup = NSNumber.init(value: isGroup)
            
            let user = NTUser.init(userData: userData)
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
     - parameter managedObjectContext: context in which to inisert.
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
}

extension NTUserData: ManagedObjectType{
    static var entityName: String = "NTUserData"
}
