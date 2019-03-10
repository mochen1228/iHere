//
//  StudentClassesTableViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/5/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class StudentClassesTableViewController: UITableViewController, UIApplicationDelegate{

    var classes = [PFObject]()
    let classesRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        classesRefreshControl.addTarget(self, action: #selector(loadClasses), for: .valueChanged)
        tableView.refreshControl = classesRefreshControl
        tableView.scrollsToTop = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadClasses()
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "initialViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
        PFUser.logOut()
    }
    
    @objc func loadClasses() {
        let query = PFQuery(className:"Class")
        query.findObjectsInBackground { (results: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let results = results {
                print("success")
                self.classes = results
                self.tableView.reloadData()
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension StudentClassesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return classes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentClassCell",
                                                 for: indexPath) as! StudentClassTableViewCell
        let classData = classes[indexPath.row]
        
        cell.courseNumberLabel.text = classData["number"] as! String
        cell.courseNameLabel.text = classData["name"] as! String
        cell.courseLocationLabel.text = classData["location"] as! String
        cell.courseTimeLabel.text = classData["time"] as! String
        cell.courseInstructorLabel.text = "Chen Mo"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.classes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
