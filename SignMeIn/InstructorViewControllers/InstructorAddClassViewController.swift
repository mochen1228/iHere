//
//  InstructorAddClassViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/5/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//
// References for passing data with delegates:
// https://medium.com/ios-os-x-development/pass-data-with-delegation-in-swift-86f6bc5d0894

import UIKit
import MapKit
import Parse

class InstructorAddClassViewController: UIViewController, AddLocationViewControllerDelegate {
    
    
    @IBOutlet weak var roundedPickLocation: UIButton!
    func finishPassing(location: MKPlacemark) {
        print("Received:")
        print(location)
        
        // Rounding to the 8th decimal point
        latituteTextField.text = String(format: "%.8f", location.coordinate.latitude)
        longituteTextField.text = String(format: "%.8f", location.coordinate.longitude)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddLocationViewController {
            destination.delegate = self
        }
    }
   
    @IBOutlet weak var courseNumberTextField: UITextField!
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var classLocationTextField: UITextField!
    @IBOutlet weak var meetingTimeTextField: UITextField!
    @IBOutlet weak var signInCodeTextField: UITextField!
    
    // ATTENTION:
    // The widths of these text fields are fixed
    // Needs to be fixed with autolayout
    @IBOutlet weak var latituteTextField: UITextField!
    @IBOutlet weak var longituteTextField: UITextField!
    
    @IBAction func onPickLocationButton(_ sender: Any) {
        performSegue(withIdentifier: "showMapSegue", sender: nil)
    }
    
    @IBAction func onDoneButton(_ sender: Any) {
        let newClass = PFObject(className: "Class")
        newClass["active"] = false
        newClass["instructorId"] = PFUser.current()?.objectId
        newClass["number"] = courseNumberTextField.text
        newClass["name"] = courseNameTextField.text
        newClass["location"] = classLocationTextField.text
        newClass["time"] = meetingTimeTextField.text
        newClass["latitute"] = latituteTextField.text
        newClass["longitute"] = longituteTextField.text
        newClass["students"] = []
        
        // Set default sign in code if the user never entered one
        let code = signInCodeTextField.text
        if code == "" {
            newClass["code"] = "code"
        } else {
            newClass["code"] = code
        }


        newClass.saveInBackground(block: {(success, error) in
            if success {
                print("post saved")
                // Add this class to instructor list of classes
                var currentClasses = PFUser.current()!["classes"] as! [String]
                currentClasses.append(newClass.objectId!)
                PFUser.current()!["classes"] = currentClasses
                PFUser.current()?.saveInBackground()
            } else {
                print("cannot save post")
            }
        })
        
        navigationController?.popViewController(animated: true)

        
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        roundedPickLocation.layer.cornerRadius = 25


        // Do any additional setup after loading the view.
    }
    

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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



