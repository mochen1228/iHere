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
    var selectedClass: PFObject?
    let classesRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classesRefreshControl.addTarget(self, action: #selector(loadClasses), for: .valueChanged)
        tableView.refreshControl = classesRefreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadClasses()
    }

//    @IBAction func onLogoutButton(_ sender: Any) {
//        // Logout and segue to the initial VC
//        let main = UIStoryboard(name: "Main", bundle: nil)
//        let loginViewController = main.instantiateViewController(withIdentifier: "initialViewController")
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        delegate.window?.rootViewController = loginViewController
//        PFUser.logOut()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedClassSegue" {
            if let destinationVC = segue.destination as? SignedInStudentsViewController {
                destinationVC.selectedClass = selectedClass
                selectedClass = nil
            }
        }
    }
    
    @objc func loadClasses() {
        // Query the classes that the current instructor created
        // Reload data upon finishing the query
        let query = PFQuery(className:"Class")
        query.whereKey("instructorId", equalTo:PFUser.current()?.objectId)
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

extension InstructorClassesTableViewController {
    // Extensions for tableview VC
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if classes.count > 0 {
            tableView.restore()
            return classes.count
        } else {
            tableView.setEmptyMessage("You haven't created any classes")
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructorClassCell",
                                                 for: indexPath) as! InstructorClassTableViewCell
        let classData = classes[indexPath.row]
        
        // Configuring cell labels
        cell.courseNumberLabel.text = classData["number"] as! String
        cell.courseNameLabel.text = classData["name"] as! String
        cell.courseLocationLabel.text = classData["location"] as! String
        cell.courseTimeLabel.text = classData["time"] as! String
        let currentUser = PFUser.current()!
        cell.courseInstructorLabel.text = (currentUser["firstname"] as! String)
            + " " + (currentUser["lastname"] as! String)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Swifpe left to show delete button
        // This action will remove all references of this "Class" object
        //      from the parse dababase
        //
        
        // TODO:
        // Remove all associated check in objects in all students
        if editingStyle == .delete {
            let toRemove = classes[indexPath.row]
            let toRemoveCheckins = toRemove["checkins"]! as! [PFObject]
            
            for checkin in toRemoveCheckins {
                checkin.deleteInBackground { (success, error) in
                    if let error = error {
                        print("Error trying to remove checkin session:")
                        print(checkin)
                    }
                }
            }
            
            let userCurrentClasses = PFUser.current()!["classes"]!
            for classes in userCurrentClasses as! [PFObject] {
                print(classes.objectId!)
                print(toRemove.objectId)
                if classes.objectId!.isEqual(toRemove.objectId!) {
                    print("hi")
                    print([classes])
                    PFUser.current()!.removeObjects(in: [classes], forKey: "classes")
                    PFUser.current()!.saveInBackground()
                }
            }
            
             toRemove.deleteInBackground()
            
            self.classes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform actions when user taps on a cell
        // Pass selected class data to the class details VC
        selectedClass = classes[indexPath.row]
        performSegue(withIdentifier: "selectedClassSegue", sender: nil)
    }
}
