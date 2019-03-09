//
//  InstructorClassesTableViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/5/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class InstructorClassesTableViewController: UITableViewController, UIApplicationDelegate {

    var classes = [PFObject]()

    @IBAction func onLogoutButton(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "initialViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
        PFUser.logOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadClasses()
    }

    func loadClasses() {
        let query = PFQuery(className:"Class")
        query.whereKey("instructorId", equalTo:PFUser.current()?.objectId)
        query.findObjectsInBackground { (results: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let results = results {
                print("success")
                // Do something with the found objects
//                for object in objects {
//                    print(object.objectId as Any)
//                }
                self.classes = results
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell",
                                                 for: indexPath) as! InstructorClassTableViewCell
        let classData = classes[indexPath.row]
        
        cell.courseNumberLabel.text = classData["number"] as! String
        cell.courseNameLabel.text = classData["name"] as! String
        cell.courseLocationLabel.text = classData["location"] as! String
        cell.courseTimeLabel.text = classData["time"] as! String
        cell.courseInstructorLabel.text = "Richard Pattis"
        // Configure the cell...

        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
