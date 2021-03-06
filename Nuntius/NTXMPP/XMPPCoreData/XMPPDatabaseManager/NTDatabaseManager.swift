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
    var mainManagedObjectContext: NSManagedObjectContext?
    static var databaseManager: NTDatabaseManager!
    var privateManagedObjectContext: NSManagedObjectContext?
    
    public override init() {
        super.init()
    }
    
    /**
     Shared instance for database manager to handle database related functions.
     - Returns: Shared instance of database manager
     */
    class func sharedManager() -> NTDatabaseManager{
        if databaseManager == nil{
            databaseManager = NTDatabaseManager()
        }
        return databaseManager
    }
    
    
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
    
    //Context for writing data to persistent store
    lazy var writerManagedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    /**
     Returns the context related to the main thread. Use this context for UI related tasks. DO NOT USE THIS THREAD FOR SAVING DATA.
     - Returns: managedObjectContext for main thread
     */
    func getMainManagedObjectContext() -> NSManagedObjectContext{
        if mainManagedObjectContext == nil{
            mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mainManagedObjectContext?.parent = writerManagedObjectContext
            mainManagedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return mainManagedObjectContext!
        }
        return mainManagedObjectContext!
    }
    
    /**
     Returns the context as a child of main context. Use this context for all operations. USE THIS THREAD FOR SAVING DATA
     - Returns: managedObjectContext
     */
    func getChildContext() -> NSManagedObjectContext {
        
        if privateManagedObjectContext == nil{
            privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateManagedObjectContext!.parent = NTDatabaseManager.sharedManager().getMainManagedObjectContext()
            privateManagedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return privateManagedObjectContext!
        }
        return privateManagedObjectContext!
    }
    
    // MARK: - Core Data Saving support
    /**
     Save the changes of context and passes to parent context.
     - parameter context: Context for which data need to be saved.
     - parameter completion: Completion block called on saving the data
     
     */
    func saveChildContext(context: NSManagedObjectContext?, completion:(Bool) -> ()){
        context?.performAndWait {
            if (context?.hasChanges)!{
                do{
                    try context?.save()
                    completion(true)
                }
                catch{
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    completion(false)
                    abort()
                }
            }
        }
    }
    
    /**
     Saves the changes of child thread and passes to parent context.
     */
    func saveChildContext(){
        privateManagedObjectContext?.performAndWait {
            if (privateManagedObjectContext?.hasChanges)!{
                do{
                    try privateManagedObjectContext?.save()
                }
                catch{
                    print("\(error)")
                }
            }
        }
    }
    
    
    /**
     Saves data in maincontext which passes it to writer context. Writer context writes the data in persistent store.
     */
    func saveToPersistentStore(){
        if(self.getMainManagedObjectContext().hasChanges){
            self.getMainManagedObjectContext().performAndWait({
                do{
                    try self.getMainManagedObjectContext().save()
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
    
}
