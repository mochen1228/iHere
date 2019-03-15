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
        if classes.count > 0 {
            tableView.restore()
            return classes.count
        } else {
            tableView.setEmptyMessage("There are no classes")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentClassCell",
                                                 for: indexPath) as! StudentClassTableViewCell
        let classData = classes[indexPath.row]
        
        cell.courseNumberLabel.text = classData["number"] as? String
        cell.courseNameLabel.text = classData["name"] as? String
        cell.courseLocationLabel.text = classData["location"] as? String
        cell.courseTimeLabel.text = classData["time"] as? String
        
        // Retrieve instructor name
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: classData["instructorId"])
        query.findObjectsInBackground { (result, error) in
            if result != nil {
                let instructor = result?.first!
                cell.courseInstructorLabel.text = (instructor!["firstname"] as! String) + " " + (instructor!["lastname"] as! String)
            } else {
                print("Error retrieving instructor information")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform actions when user taps on a cell
        // Pass selected class data to the class details VC
        selectedClass = classes[indexPath.row]
        performSegue(withIdentifier: "studentSelectedClassSegue", sender: nil)
    }
}

extension UITableView {
    // This extension is to make the table view display a label when it
    //      is empty.
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        // messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
