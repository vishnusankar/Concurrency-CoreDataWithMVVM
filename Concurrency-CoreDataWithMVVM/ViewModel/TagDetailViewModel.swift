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
    
    private let mainMOC : MainMOC
    private var currentTagObjectId : NSManagedObjectID
    var tagObject : TagEntity
    
    init(currentTag : NSManagedObjectID, writerMOC : MainMOC) {
        self.currentTagObjectId = currentTag
        self.mainMOC = writerMOC
        
        do {
            tagObject = try mainMOC.getContext().existingObject(with: currentTagObjectId) as! TagEntity
        } catch _ as NSError {
            fatalError("Selected object ID not available at context")
        }
    }
    
    func saveContext() {
        if self.mainMOC.getContext().hasChanges == true {
            self.mainMOC.saveMainContext()
        }
        
    }
}
