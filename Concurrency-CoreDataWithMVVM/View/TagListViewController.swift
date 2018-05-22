//
//  ViewController.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 17/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import UIKit
import CoreData

class TagListViewController : UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var writerMOC = WriterMOC()
    var mainManagedObjectContext : MainMOC?
    var workerMOC : WorkerMOC?
    var tagViewListModels : TagViewListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tagViewListModels = TagViewListModel(managedObjectContext: CoreDataHelper().mainMOC, delegate: self)
        mainManagedObjectContext = MainMOC(parentContext: self.writerMOC.getContext())
        self.workerMOC = WorkerMOC(parentContext: self.writerMOC.getContext())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTag(_ sender: Any) {
        
        let randomNo = arc4random()%100
        _ = self.createNewTagEntity(tagName: "Tag\(randomNo)",context: (mainManagedObjectContext?.getContext())!)
        if (self.mainManagedObjectContext?.getContext().hasChanges)! {
            do {
                try mainManagedObjectContext?.saveMainContext()
                self.tableView.reloadData()
            } catch let error as NSError {
                fatalError("context save failed \(error)")
            }
        }
    }
    
    func createNewTagEntity(tagName : String, context : NSManagedObjectContext) -> TagEntity {
        
        let newTagEntry = TagEntity(context:context)
        newTagEntry.lastUpdated = Date()
        newTagEntry.tag = tagName
        
        return newTagEntry
    }
    
    @IBAction func copyAllTags(_ sender: Any) {
                
        self.workerMOC?.getContext().perform({
            
            do {
                let fetchReq = NSFetchRequest<TagEntity>(entityName: "TagEntity")
                
                if let allTagsArray = try self.workerMOC?.getContext().fetch(fetchReq) {
                    for tagObj  in allTagsArray {
                        let unwrapTagObj : TagEntity = tagObj as TagEntity
                        let tagStr : String = unwrapTagObj.tag ?? ""
                        var index = 0
                        
                        for _ in 0...10 {
                            
                            let newObj = self.createNewTagEntity(tagName: tagStr,context: (self.workerMOC?.getContext())!)
                            index += 1
                            
                            if (index % 10) == 0 {
                                self.workerMOC?.saveWorkerContext()
                            }
                        }
                    }
                    if self.workerMOC?.getContext().hasChanges == true {
                        self.workerMOC?.saveWorkerContext()
                        
                        self.tagViewListModels?.performFetcht()
                    }
                }
            } catch let error as NSError {
                fatalError("Unresoved error")
            }
        })
    }
    
    @IBAction func descendingAllTags(_ sender: Any) {
        self.tagViewListModels?.sortingManagedObjects(ascendingOrder: false)
    }
    
    @IBAction func ascendingAllTags(_ sender: Any) {
        self.tagViewListModels?.sortingManagedObjects(ascendingOrder: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let viewCont = segue.destination as! TagDetailViewController
        if let selectedCell = sender as? UITableViewCell {
            let view = selectedCell.contentView.subviews
//            if let label = view.first as? UILabel {
//                viewCont.tagTextField.text = label.text!
//            }
            if let indexPath = self.tableView.indexPath(for: selectedCell) {
                let selectedTag = self.tagViewListModels?.cellRowAtIndexPath(indexPath: indexPath)
                
                do {
                    let tagDetailViewModelObj = TagDetailViewModel(currentTag: (selectedTag?.objectID)!, writerMOC: writerMOC)
                    viewCont.tagDetailViewModel = tagDetailViewModelObj
                    
                } catch let error as NSError {
                    fatalError("Selected object ID not available at context")
                }
            }else {
                fatalError("Selected cell not available in tableview")
            }
        }else {
            fatalError("Selected cell is nil")
        }
    }
}

extension TagListViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagViewListModels?.numberofRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagTableViewCellIdentifier")

        let tagEntity = tagViewListModels?.cellRowAtIndexPath(indexPath: indexPath)
        let subviews = cell?.contentView.subviews.filter({ $0.tag == 1})
        let label : UILabel = subviews?.first as! UILabel
        label.text = tagEntity?.tag
        
        return cell!
    }
}

extension TagListViewController : TagViewListModelProtocol {
    func dataUpdated() {
        self.tableView.reloadData()
    }
}
