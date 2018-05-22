//
//  WorkerMOC.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 21/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import Foundation
import CoreData

class WorkerMOC {
    
    private lazy var context : NSManagedObjectContext  = {
        let tempMainMOC = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        return tempMainMOC
    }()
    
    private let parentContext : NSManagedObjectContext
    
    init(parentContext : NSManagedObjectContext) {
        
        self.parentContext = parentContext
        self.getContext().parent = parentContext
    }
    
    func getContext() -> NSManagedObjectContext {
        return context
    }
    
    func saveWorkerContext() {
        
        //1st level child save
        guard context.hasChanges else { return }
        
        do {
            print("worker started")
            try context.save()
            print("worker ended")
        } catch let nserror as NSError {
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        //Root level save
        guard (self.parentContext.hasChanges) else { return }
        
        self.parentContext.perform({
            do {
                print("worker - writer started")
                try self.parentContext.save()
                print("worker - writer Ended")
            } catch let nserror as NSError {
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        })
    }
}
