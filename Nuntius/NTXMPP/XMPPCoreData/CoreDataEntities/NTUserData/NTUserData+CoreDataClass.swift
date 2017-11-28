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
    static var userIdToObjectId: [String:NSManagedObjectID] = [:]
    static var groupIdToObjectId: [String:NSManagedObjectID] = [:]
//    static var contactMOC: NSManagedObjectContext = {
//        let context = NTDatabaseManager.sharedManager().getChildContext()
//        return context
//    }()
    
    class func populateUserObjectDict() {
        
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        
        childMOC.perform {
            let fetchRequest = NTUserData.userFetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "\(userDataIsGroup) == %@", NSNumber.init(value: false))
            do{
                let result:[NTUserData] = try childMOC.fetch(fetchRequest)
                for userData in result {
                    userIdToObjectId[userData.userId!] = userData.objectID
                }
                
            }
            catch{
                print("Error - \(error)")
            }
        }
        
        childMOC.perform {
            let fetchRequest = NTUserData.userFetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "\(userDataIsGroup) == %@", argumentArray: [NSNumber.init(value: true)])
            do{
                let result:[NTUserData] = try childMOC.fetch(fetchRequest)
                for userData in result {
                    groupIdToObjectId[userData.userId!] = userData.objectID
                }
                
            }
            catch{
                print("Error - \(error)")
            }
        }
        
        
    }
    
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
    
    class func insertUserOnBackground(userId: String, isGroup: Bool, managedObjectContext: NSManagedObjectContext, completion: @escaping (NTUser?) -> ()) {
        managedObjectContext.perform {
            if let user = self.userData(For: userId, isGroup: isGroup, managedObjectContext: managedObjectContext){
                completion(NTUser.init(userData: user))
            }
            
            let userData: NTUserData = managedObjectContext.insertObject()
            userData.userId = userId
            userData.isGroup = NSNumber.init(value: isGroup)
            
            let user = NTUser.init(userData: userData)
            
            do{
                try managedObjectContext.save()
                completion(user)
                self.populateUserObjectDict()
            }
            catch{
                print(error)
                completion(nil)
            }
        }
    }
    
    class func insertUser(userId: String, isGroup: Bool, managedObjectContext: NSManagedObjectContext) -> NTUserData? {
        if let user = self.userData(For: userId, isGroup: isGroup, managedObjectContext: managedObjectContext){
            return user
        }
        
        let userData: NTUserData = managedObjectContext.insertObject()
        userData.userId = userId
        userData.isGroup = NSNumber.init(value: isGroup)
        
        let userObjectId = userData.objectID
        
        do{
            if let savedUserData: NTUserData = managedObjectContext.object(with: userObjectId) as? NTUserData{
                self.populateUserObjectDict()
                return userData
            }
        }
        catch{
            print(error)
            return nil
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
