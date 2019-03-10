//
//  SignedInStudentsTableViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/9/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class SignedInStudentsTableViewController: UITableViewController {

    var selectedClass: PFObject?
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = selectedClass?["number"] as! String
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}
