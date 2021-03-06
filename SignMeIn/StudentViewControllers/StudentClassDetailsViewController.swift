//
//  StudentClassDetailsViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/9/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//
//  For information on SCLAlertView:
//  https://github.com/vikmeup/SCLAlertView-Swift

import UIKit
import Parse
import MapKit
import SCLAlertView
import CoreLocation

class StudentClassDetailsViewController: UIViewController {

    var selectedClass: PFObject? = nil
    
    @IBOutlet weak var roundedCheckInButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationItem!

    var pin = MKPointAnnotation()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    
    let historyRefreshControl = UIRefreshControl()

    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseLocationLabel: UILabel!
    
    var checkinHistory = [PFObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBAction func onCheckInButton(_ sender: Any) {
        if isLegalCheckInLocation(within: 50.0) {
            showCheckInCodeAlert()
        } else {
            showIllegalLocationAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start loading location right away
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = selectedClass!["number"] as? String
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        historyRefreshControl.addTarget(self, action: #selector(loadClassHistory), for: .valueChanged)
        tableView.refreshControl = historyRefreshControl
        
        loadMap()
        loadLocationManager()
        loadLabels()
        loadClassHistory()
        roundedCheckInButton.layer.cornerRadius = 15
        tableView.reloadData()
    }
}

extension StudentClassDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    // Extension protocols for table view
    func numberOfSections(in tableView: UITableView) -> Int {
        // TODO:
        // Section the check in entries with days
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if checkinHistory.count > 0 {
            tableView.restore()
            return checkinHistory.count
        } else {
            tableView.setEmptyMessage("You have no check in history")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentClassHistoryCell", for: indexPath) as! StudentClassHistoryTableViewCell
        
        // To reverse the check in entries
        // The most recent entries will display at the top
        let totalEntries = checkinHistory.count
        let currentCheckin = self.checkinHistory[totalEntries - indexPath.row - 1]

        let currentDate = currentCheckin.createdAt!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        
        // Filling the text for date label
        cell.checkinTimeLabel.text = formatter.string(from: currentDate)
        return cell
        
    }
}

extension StudentClassDetailsViewController {
    // Extensions for loading the content of the VC
    func loadMap() {
        // Set default region for the map, centered towards the
        //      location of the lecture hall
        // TODO:
        // Set the center of the default region between the user location
        //      and the class location, set the region diameter the
        //      distance between the class and the user
        var region = MKCoordinateRegion()
        region.center.latitude = Double(selectedClass!["latitute"]! as! String)!
        region.center.longitude = Double(selectedClass!["longitute"] as! String)!
        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        mapView?.setRegion(region, animated: true)
        
        // Drop a pin on the location of the classroom/lecture hall
        pin.title = selectedClass!["building"] as? String
        pin.coordinate = region.center
        mapView?.addAnnotation(pin)
    }
    
    func loadLabels() {
        // To load labels for class information
        courseNameLabel.text = selectedClass!["name"] as? String
        courseLocationLabel.text = selectedClass!["location"] as? String
    }
    
    @objc func loadClassHistory() {
        // To load check in histories for this particular class
        // Step 1: Retrieve all check in entries that is associated with the student
        // Step 2: Using a for loop, add all the entries that are related
        //          to this class
        checkinHistory = [PFObject]()
        
        // Step 1
        let query = PFQuery(className: "checkin")
        query.whereKey("student", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (results, error) in
            if (results != nil) {
                // Step 2
                for r in results! {
                    if (r["class"] as! PFObject).objectId == self.selectedClass!.objectId {
                        self.checkinHistory.append(r)
                    }
                }
                print("Successfully retrieved check in data from this class")
            } else {
                print("Cannot retrieve check in data")
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension StudentClassDetailsViewController {
    // Extensions for alert views
    func showCheckInCodeAlert() {
        // This will pop up a alert to prompt the user to enter a check in code
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false, showCircularIcon: false, shouldAutoDismiss: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let code = alert.addTextField("Enter code here...")
        // App theme yellow color
        let color = UIColor(red: 247.0/255.0, green: 224.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        alert.addButton("Check In", backgroundColor: color, textColor: UIColor.black) {
            print("Text value: \(String(describing: code.text))")
            // ATTENTION:
            // This is the part that checks if the user entered code is the
            //      same code as the instructor provided code
            //      if not match, the window won't dismiss
            // TODO:
            // Find a way to tell the user that the code is wrong
            if self.isLegalCheckInCode(code.text!) {
                self.saveCheckInSession()
                // Dismiss the window
                alert.hideView()
            }
        }
        alert.addButton("Cancel", backgroundColor: UIColor.black,
                        textColor: UIColor.white) {
            alert.hideView()
            print("Cancel tapped")
        }
        alert.showEdit("Verify Check In Code",
                       subTitle: "Your instructor has requested a check in code",
                       colorStyle: 0xf7e090)
    }
    
    func showIllegalLocationAlert() {
        // This will pop up a alert telling the user that he is too far from the class
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false, showCircularIcon: false
        )
        let alert = SCLAlertView(appearance: appearance)
        // Dark red color
        alert.addButton("Fine", backgroundColor: UIColor(red: 139/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0), textColor: UIColor.white) {
            alert.hideView()
            print("Cancel tapped")
        }
        alert.showError("Nice Try", subTitle: "We know you are not in the classroom...")
        
    }
}

extension StudentClassDetailsViewController {
    // Extensions for verifications
    func isLegalCheckInCode(_ code: String) -> Bool {
        // Fetch the code from Parse server and verify
        // NOTE:
        // The previous approach that we fetch the code from locally stored "selectedClass"
        //      will always give us the code at the time when user entered this page
        // If the instructor updated the code after the user entered this page, this function
        //      will compare with the old check in code
        
        let query = PFQuery(className: "Class")
        query.whereKey("objectId", equalTo: selectedClass?.objectId as! String)
        
        // ATTENTION:
        // This will block the main thread if there's no internet connection
        let results = try? query.findObjects()
        return code == (results!.first!["code"] as! String)
    }
    
    func isLegalCheckInLocation(within threshold: Double) -> Bool {
        // Calculate the distance between the class room and user in METERS
        // If the distance is greater than the threshold, it will return false
        // Threshold have to be in double, and the unit is METERS
        // https://en.wikipedia.org/wiki/Metre
        if currentLocation != nil {
            let coordinate1 = CLLocation(latitude: (currentLocation?.coordinate.latitude)!,
                                         longitude: (currentLocation?.coordinate.longitude)!)
            let coordinate2 = CLLocation(latitude: Double(selectedClass!["latitute"] as! String)!,
                                         longitude: Double(selectedClass!["longitute"] as! String)!)
            
            let distanceInMeters = coordinate2.distance(from: coordinate1)
            print("Current distance from the user to the class is:", distanceInMeters, "meters")
            if distanceInMeters > threshold {
                return false
            }
            return true
        } else {
            return false
        }
        
    }
}

extension StudentClassDetailsViewController: CLLocationManagerDelegate {
    func loadLocationManager() {
        // Mandatory methods to get current user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let location = locationManager.location else {
                print("Could not get current location")
                return
            }
            currentLocation = location
            print("user is currently at: ", currentLocation?.coordinate)
        }
    }
}

extension StudentClassDetailsViewController {
    func saveCheckInSession() {
        // Creating the "checkin" class to store user check in sessions
        //      to both the current user and the class
        
        // Save checkin object
        //      Save checkin object pointer to selected class
        //          Save checkin object pointer to current user
        let checkin = PFObject(className: "checkin")
        checkin["class"] = self.selectedClass
        checkin["student"] = PFUser.current()
        checkin.saveInBackground { (success, error) in
            if success {
                print("check in successfully saved")
                // Add to class
                self.selectedClass!.add(checkin, forKey: "checkins")
                self.selectedClass!.saveInBackground { (success, error) in
                    if success {
                        print("check in successfully saved to class")
                        // Add to student
                        PFUser.current()?.add(checkin, forKey: "checkins")
                        PFUser.current()?.saveInBackground{ (success, error) in
                            if success {
                                print("check in successfully saved to user")
                            } else {
                                print("check in not saved to yser")
                            }
                        }
                    } else {
                        print("check in not saved to class")
                    }
                }
            } else {
                print("check in cannot be saved")
            }
            self.loadClassHistory()
        }
        
    }
}
