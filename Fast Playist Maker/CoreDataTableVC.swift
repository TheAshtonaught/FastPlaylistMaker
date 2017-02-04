//
//  CoreDataTableVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/27/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableVC: UITableViewController, NSFetchedResultsControllerDelegate {

    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            
            fetchedResultsController?.delegate = self
            search()
            tableView.reloadData()
        }
    }
    
    init(fetchedResultsController fc: NSFetchedResultsController<NSFetchRequestResult>, style: UITableViewStyle = .plain) {
        fetchedResultsController = fc
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }

    func search() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let err as NSError {
                print("could not perform fetch \(err.localizedDescription)")
            }
        }
    }
//Mark: Fetched results controller delegate
    
    //TODO: add 
    

}