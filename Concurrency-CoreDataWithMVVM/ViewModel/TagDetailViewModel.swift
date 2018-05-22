//
//  TagDetailViewModel.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 18/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import Foundation
import CoreData

class TagDetailViewModel {
    
    private let writerMOC : WriterMOC
    private var currentTagObjectId : NSManagedObjectID
    var tagObject : TagEntity
    
    init(currentTag : NSManagedObjectID, writerMOC : WriterMOC) {
        self.currentTagObjectId = currentTag
        self.writerMOC = writerMOC
        
        do {
            tagObject = try writerMOC.getContext().existingObject(with: currentTagObjectId) as! TagEntity
        } catch _ as NSError {
            fatalError("Selected object ID not available at context")
        }
    }
    
    func saveContext() {
        if self.writerMOC.getContext().hasChanges == true {
            self.writerMOC.saveWriterContext()
        }
        
    }
}
