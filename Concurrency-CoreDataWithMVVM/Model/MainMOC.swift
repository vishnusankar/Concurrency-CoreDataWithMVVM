//
//  WorkerMOC.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 21/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import Foundation
import CoreData

class MainMOC {
    
    private lazy var context : NSManagedObjectContext = {
        let tempMainMOC = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        
        return tempMainMOC
    }()
    
    private let parentContext : NSManagedObjectContext
    
    init(parentContext : NSManagedObjectContext) {
        
        self.parentContext = parentContext
        self.context.parent = parentContext
    }
    
    func getContext() -> NSManagedObjectContext {
        return self.context
    }
    
    func saveMainContext() {
        
        //1st level child save
        guard context.hasChanges else { return }
        
        context.perform({
            do {
                print("main started")
                try self.context.save()
                print("main ended")
            } catch let nserror as NSError {
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            //Root level save
            guard self.parentContext.hasChanges else { return }
            
            self.parentContext.perform({
                do {
                    print("writer started")
                    try self.parentContext.save()
                    print("writer Ended")
                } catch let nserror as NSError {
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            })
        })
    }

}
