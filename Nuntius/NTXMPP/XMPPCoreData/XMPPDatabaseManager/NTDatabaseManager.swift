//
//  NTDatabaseManager.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import CoreData

class NTDatabaseManager: NSObject {
    
    let databaseName = "NTXMPPDataModel"
    var managedObjectContext: NSManagedObjectContext?
    static var databaseManager: NTDatabaseManager!
    
    // MARK: - CoreData Stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cadiridris.coreDataTemplate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: databaseName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(databaseName).sqlite")
        print(url)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var writerManagedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    func mainManagedObjectContext() -> NSManagedObjectContext{
        if managedObjectContext == nil{
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext?.parent = writerManagedObjectContext
            managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return managedObjectContext!
        }
        return managedObjectContext!
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if (managedObjectContext?.hasChanges)! {
            do {
                try managedObjectContext?.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func getChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = NTDatabaseManager.sharedManager().mainManagedObjectContext()
        return context
    }
    
    func saveToPersistentStore(){
        if(self.mainManagedObjectContext().hasChanges){
            self.mainManagedObjectContext().performAndWait({
                do{
                    try self.mainManagedObjectContext().save()
                    if(self.writerManagedObjectContext.hasChanges){
                        self.writerManagedObjectContext.performAndWait({
                            do{
                                try self.writerManagedObjectContext.save()
                            }
                            catch{
                                let nserror = error as NSError
                                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                                abort()
                            }
                        })
                    }
                }
                catch{
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            })
        }
        
    }
    
    class func sharedManager() -> NTDatabaseManager{
        if databaseManager == nil{
            databaseManager = NTDatabaseManager()
        }
        return databaseManager
    }
    
    public override init() {
        super.init()
    }
    
}
