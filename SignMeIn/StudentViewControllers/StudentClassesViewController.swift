//
//  StudentClassesViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/9/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class StudentClassesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var classes = [PFObject]()
    var selectedClass: PFObject?
    var currentUser: PFUser?
    let classesRefreshControl = UIRefreshControl()
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = PFUser.current()!
        classesRefreshControl.addTarget(self, action: #selector(loadClasses), for: .valueChanged)
        tableView.refreshControl = classesRefreshControl
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationBar.title = (currentUser!["firstname"] as! String) + " " + (currentUser!["lastname"] as! String)
        // Remove empty cells in the table view
        tableView.tableFooterView = UIView()

        // tableView.scrollsToTop = true
    }

    override func viewWillAppear(_ animated: Bool) {
        loadClasses()
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        // Log out button that will bring the user back to the initial view
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "initialViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
        PFUser.logOut()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentSelectedClassSegue" {
            if let destinationVC = segue.destination as? StudentClassDetailsViewController {
                destinationVC.selectedClass = selectedClass
                selectedClass = nil
            }
        }
    }
    
    @objc func loadClasses() {
        // Query the database and retrieve ALL classes that are created
        let query = PFQuery(className:"Class")
        query.findObjectsInBackground { (results: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let results = results {
                print("StudentClassesVC load data: Success")
                self.classes = results
                self.tableView.reloadData()
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension StudentClassesViewController: UITableViewDelegate, UITableViewDataSource {
    // Extensions protocols for tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform actions when user taps on a cell
        // Pass selected class data to the class details VC
        selectedClass = classes[indexPath.row]
        performSegue(withIdentifier: "studentSelectedClassSegue", sender: nil)
    }
}

