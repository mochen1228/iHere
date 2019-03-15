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
    
    @IBOutlet weak var changeCodeButton: UIButton!
    @IBAction func onChangeCodeButton(_ sender: Any) {
        showUpdateCodeAlert()
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
        changeCodeButton.layer.cornerRadius = 15
        loadCheckInCodeLabel()
        // Loading table view
        tableView.delegate = self
        tableView.dataSource = self
        // Loading refresh controls
        let checkinRefreshControl = UIRefreshControl()
        checkinRefreshControl.addTarget(self, action: #selector(loadCheckins), for: .valueChanged)
        tableView.refreshControl = checkinRefreshControl
        
    }
}

extension SignedInStudentsViewController {
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
    
    func updateCheckInCode(with newCode: String) -> Void {
        // Save the new check in code to Parse and update the label that
        //      displays the check in code
        let oldCheckInCode = selectedClass!["code"]
        selectedClass!["code"] = newCode
        selectedClass?.saveInBackground {(success, error) in
            if success {
                print("Updating code success")
                self.loadCheckInCodeLabel()
            } else {
                print("Error in updating the sign in code")
                print("Restoring the old check in code")
                self.selectedClass!["code"] = oldCheckInCode
            }
        }
    }
    
    func loadCheckInCodeLabel() {
        checkInCodeLabel.text = selectedClass!["code"] as? String
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
    func showUpdateCodeAlert() {
        // This will pop up a alert to prompt the user to enter a check in code
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let code = alert.addTextField("Enter code here...")
        let color = UIColor(red: 247.0/255.0, green: 224.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        alert.addButton("Confirm", backgroundColor: color, textColor: UIColor.black) {
            print("Text value: \(String(describing: code.text))")
            if code.text != nil {
                alert.hideView()
                // Update the class check in code
                self.updateCheckInCode(with: code.text!)
            }
        }
        alert.addButton("Cancel", backgroundColor: UIColor.black,
                        textColor: UIColor.white) {
                            alert.hideView()
                            print("Cancel tapped")
        }
        alert.showEdit("New Check In Code",
                       subTitle: "This will update the code required for all students",
                       colorStyle: 0xf7e090)
    }
}
