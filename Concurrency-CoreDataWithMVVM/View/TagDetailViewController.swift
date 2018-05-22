//
//  File.swift
//  Concurrency-CoreDataWithMVVM
//
//  Created by vishnusankar on 18/05/18.
//  Copyright © 2018 vishnusankar. All rights reserved.
//

import UIKit

class TagDetailViewController: UIViewController {
    
    var tagDetailViewModel : TagDetailViewModel?
    
    @IBOutlet weak var tagTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tagTextField.text = tagDetailViewModel?.tagObject.tag
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func updateTag(_ sender: Any) {
        
        self.tagDetailViewModel?.tagObject.tag = self.tagTextField.text
        self.tagDetailViewModel?.saveContext()
    }
}
