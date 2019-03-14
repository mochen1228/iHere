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
    var checkins = [PFObject]()
    var checkedInStudents = [PFUser]() {
        // Whenver this value is updated, reload the table view
        // This is to prevent reloading the table view before the
        //      check in data is actually retrieved and causing
        //      index error
        didSet{
            print("check in list updated")
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBAction func onClearButton(_ sender: Any) {
        // TODO:
        // For each student, clear check in from their history
        
        // Clear all check in historied for this class
        selectedClass!["checkins"] = [PFObject]()
        selectedClass?.saveInBackground()
        
        // Clear check in entries from Parse
        for checkin in checkins {
            checkin.deleteInBackground { (success, error) in
                if error != nil {
                    print("Error trying to remove checkin session:")
                    print(checkin)
                }
            }
        }
        
        // Clear local data for checkins
        checkins = [PFObject]()
        checkedInStudents = [PFUser]()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCheckins()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = selectedClass?["number"] as! String
        
        // Loading refresh controls
        let checkinRefreshControl = UIRefreshControl()
        checkinRefreshControl.addTarget(self, action: #selector(loadCheckins), for: .valueChanged)
        tableView.refreshControl = checkinRefreshControl

    }

    @objc func loadCheckins() {
        // To load all the students that have checked in to this class
        // There are two steps:
        //      1. Retrieve all the checkin objects related to this class
        //      2. For each check in, retrieve the student in this check in
        
        // Clear previous data
        checkins = [PFObject]()
        checkedInStudents = [PFUser]()
        
        // Retrieve checkins
        let query = PFQuery(className: "checkin")
        query.whereKey("class", equalTo: selectedClass!)
        query.findObjectsInBackground {(checkins, error) in
            if checkins != nil {
                self.checkins = checkins!

                for checkin in self.checkins {
                    // Retrieve the student in this check in
                    let query = PFQuery(className: "_User")
                    query.whereKey("objectId", equalTo: (checkin["student"] as! PFUser).objectId)
                    query.findObjectsInBackground() {(result, error) in
                        if result != [] {
                            self.checkedInStudents.append(result!.first as! PFUser)
                        }
                    }
                }
            }
        }
        self.tableView.refreshControl?.endRefreshing()
    }
}

extension SignedInStudentsTableViewController {
    // Extensions for table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        // TODO:
        // Divide checkins to sections by their date
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return checkedInStudents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "signedInCell", for: indexPath) as! InstructorCheckInTableViewCell
        let currentStudent = checkedInStudents[indexPath.row]
        let currentCheckin = checkins[indexPath.row]
        cell.studentNameLabel.text = (currentStudent["firstname"] as! String) + " " + (currentStudent["lastname"] as! String)
        cell.studentUsernameLabel.text = currentStudent.username as! String
        
        // Date formatting
        let currentDate = currentCheckin.createdAt!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        
        // Filling the text for date label
        cell.checkedInTimeLabel.text = formatter.string(from: currentDate)
        return cell
    }
}
