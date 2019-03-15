//
//  SignedInStudentsViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/14/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class SignedInStudentsViewController: UIViewController {

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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var checkInCodeLabel: UILabel!
    
    @IBAction func onChangeCodeButton(_ sender: Any) {
        
    }
    
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
        print(selectedClass)
        super.viewDidLoad()
        navigationBar.title = selectedClass?["number"] as! String
        
        // Loading table view
        tableView.delegate = self
        tableView.dataSource = self
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

extension SignedInStudentsViewController: UITableViewDelegate, UITableViewDataSource {
    // Extensions for table view
    func numberOfSections(in tableView: UITableView) -> Int {
        // TODO:
        // Divide checkins to sections by their date
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if checkedInStudents.count > 0 {
            tableView.restore()
            return checkedInStudents.count
        } else {
            tableView.setEmptyMessage("No Student have checked in yet")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension SignedInStudentsViewController {
    func showCheckInCodeAlert() {
        // This will pop up a alert to prompt the user to enter a check in code
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let code = alert.addTextField("Enter code here...")
        alert.addButton("Check In", backgroundColor: UIColor.yellow, textColor: UIColor.black) {
            print("Text value: \(String(describing: code.text))")
            // ATTENTION:
            // This is the part that checks if the user entered code is the
            //      same code as the instructor provided code
            //      if not match, the window won't dismiss
            // TODO:
            // Find a way to tell the user that the code is wrong
//            if self.isLegalCheckInCode(code.text!) {
//                self.saveCheckInSession()
//                // Dismiss the window
//                alert.hideView()
//            }
        }
        alert.addButton("Cancel", backgroundColor: UIColor.black,
                        textColor: UIColor.white) {
                            alert.hideView()
                            print("Cancel tapped")
        }
        alert.showEdit("Verify Check In Code",
                       subTitle: "Your instructor has requested a check in code",
                       colorStyle: 0xffff00)
    }
}
