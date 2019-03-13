//
//  FinishingUpViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 2/26/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class FinishingUpViewController: UIViewController {

    @IBOutlet weak var roundedSignUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

        roundedSignUpButton.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
    }
    
    var userdata: [String: String] = [:]

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    
    @IBAction func onSignUpButton(_ sender: Any) {
        // Presseing this button will:
        // 1. Create a user in the background
        // 2. Log in at the same time
        // 3. Exit login flow and enter the respective view controllers
        //      for students or instructors
        
        // Sign up for User
        var user = PFUser()
        user.username = userdata["username"]
        user.password = userdata["password"]
        user["status"] = userdata["status"]
        user["firstname"] = firstnameTextField.text!
        user["lastname"] = lastnameTextField.text!
        user["checkins"] = [PFObject]()
        user["classes"] = [String]()

        user.signUpInBackground { (success, error) in
            if success {
                // TODO:
                // Add code to dismiss all pushed controllers to
                //      the root view controller
                // The current resolution is to directly sign in
                //      after sign up
                
                // Check the selected user status and choose the
                // correct segue to perform
                let status = user["status"] as! String
                if status == "Student" {
                    self.performSegue(withIdentifier: "studentSignupSegue", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "instructorSignupSegue", sender: nil)
                }
                print("sign up success")
            } else {
                print("cannot sign up")
            }
        }
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
