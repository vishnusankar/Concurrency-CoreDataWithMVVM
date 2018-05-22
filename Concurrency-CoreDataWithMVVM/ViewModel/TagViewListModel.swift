//
//  TagViewListModel.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 18/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import Foundation
import CoreData

protocol TagViewListModelProtocol  {
    func dataUpdated()
}

class TagViewListModel : NSObject {
//    private var tagList : [TagEntity]
    private var managedObjectContext : NSManagedObjectContext
    private var delegate : TagViewListModelProtocol
    private var fetchedResultCont : NSFetchedResultsController<TagEntity>? = nil
    
    required init(managedObjectContext : NSManagedObjectContext, delegate : TagViewListModelProtocol) {
        self.managedObjectContext = managedObjectContext
        self.delegate = delegate

        super.init()
        self.initializeData()
    }
    
    func initializeData() {
    
        self.fetchedResultCont = self.tagEntityFetchedResultController()

    }
    
    func numberofRows() -> Int {
        return self.fetchedResultCont?.sections?[0].numberOfObjects ?? 0
    }
    
    func cellRowAtIndexPath(indexPath:IndexPath) -> TagEntity? {
        return self.fetchedResultCont?.object(at: indexPath)
    }
    
    func sortingManagedObjects(ascendingOrder:Bool) {
        
        let fetchrequest = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        fetchrequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: #keyPath(TagEntity.tag), ascending: ascendingOrder)
        fetchrequest.sortDescriptors = [sortDescriptor]
        self.fetchedResultCont?.delegate = nil
        self.fetchedResultCont = NSFetchedResultsController(fetchRequest: fetchrequest, managedObjectContext:managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultCont?.delegate = self
        
        self.performFetcht()
    }
    
    func performFetcht()  {
        DispatchQueue.main.async {
            do {
                try self.fetchedResultCont?.performFetch()
                self.delegate.dataUpdated()
            } catch let error as NSError {
                fatalError("\(error.userInfo)")
            }
        }
    }
    
    func tagEntityFetchedResultController() -> NSFetchedResultsController<TagEntity> {
        let fetchedResultCont = NSFetchedResultsController(fetchRequest: self.tagFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultCont.delegate = self
        do {
            try fetchedResultCont.performFetch()
        } catch let error as NSError {
            fatalError("Unresolved error: \(error)")
        }
        return fetchedResultCont
    }
    
    func tagFetchRequest() -> NSFetchRequest<TagEntity>{
        let fetchReq = NSFetchRequest<TagEntity>(entityName: "TagEntity")
        fetchReq.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(TagEntity.tag), ascending: true)
        fetchReq.sortDescriptors = [sortDescriptor]
        return fetchReq
    }
    
    func indexPath(for entity : TagEntity) -> IndexPath {
        return self.fetchedResultCont?.indexPath(forObject: entity) ?? IndexPath(row: 0, section: 0)
        
    }
}

extension TagViewListModel : NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
