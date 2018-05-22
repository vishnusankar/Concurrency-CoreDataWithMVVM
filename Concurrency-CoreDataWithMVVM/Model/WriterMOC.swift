//
//  WorkerMOC.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 21/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import Foundation
import CoreData

class WriterMOC {
    
    private lazy var context : NSManagedObjectContext  = {
    
        let tempMainMOC = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        tempMainMOC.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        
        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
        do {
            try tempMainMOC.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        return tempMainMOC
    }()
    
    private lazy var applicationDocumentDirectory : URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel : NSManagedObjectModel = {
        let modelUrl = Bundle.main.url(forResource: "TagsModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelUrl)!
    }()
    
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        return coordinator
    }()
    
    init() {
        let _ = self.getContext()
    }
    
    func getContext() -> NSManagedObjectContext {
        return self.context
    }
    
    func saveWriterContext() {
        
        //1st level child save
        guard context.hasChanges else { return }
        
        do {
            print("writer started")
            try context.save()
            print("writer ended")
        } catch let nserror as NSError {
            fatalError("writer error \(nserror), \(nserror.userInfo)")
        }
    }
}
