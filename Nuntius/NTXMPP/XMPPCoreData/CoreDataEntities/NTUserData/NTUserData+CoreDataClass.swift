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
    static let userDataUserId = "userId"
    static var userIdToObjectId: [String:NSManagedObjectID] = [:]
    
    class func populateUserObjectDict(managedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NTUserData.userFetchRequest()
        do{
            let result:[NTUserData] = try managedObjectContext.fetch(fetchRequest)
            for userData in result {
                userIdToObjectId[userData.userId!] = userData.objectID
            }
            
        }
        catch{
            print("Error - \(error)")
        }
    }
    
    class func user(For userId:String, managedObjectContext: NSManagedObjectContext) -> NTUserData?{
        
        let fetchRequest = NTUserData.userFetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "\(userDataUserId) == %@", argumentArray: [userId])
        fetchRequest.fetchLimit = 1
        do{
            let result: [NTUserData] = try managedObjectContext.fetch(fetchRequest)
            return result[0]
        }
        catch{
            print(error)
            return nil
        }
    }

}

extension NTUserData{
    public class func userFetchRequest() -> NSFetchRequest<NTUserData> {
        return NSFetchRequest<NTUserData>(entityName: "NTUserData")
    }
}

extension NTUserData: ManagedObjectType{
    static var entityName: String = "NTUserData"
}
