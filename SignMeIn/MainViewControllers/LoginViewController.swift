//
//  LoginViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 2/26/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

        roundedLoginButton.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var roundedLoginButton: UIButton!
    // Label under password textfield that displays errors messages to users
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func onLoginButton(_ sender: Any) {
        // Do login actions
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        PFUser.logInWithUsername(inBackground: username, password:password) { (user, error) in
            if user != nil {
                // Perform the segue that matches the user's status
                // Student will perform studentLoginSegue and be lead to
                //      student home screen
                // Instructor will perform instructorLoginSegue and be lead
                //      to instructor home screen
                let status = user!["status"] as! String
                if status == "Student" {
                    self.performSegue(withIdentifier: "studentLoginSegue", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "instructorLoginSegue", sender: nil)
                }
            } else {
                // Handling errors
                // If Parse could not find any matching usernames or password
                if error?.localizedDescription as! String == "Invalid username/password."{
                    print("invalid username/password")
                    self.errorLabel.text? = "Invalid username/password"
                } else {
                    // If the connection takes too long
                    // Usually caused by no internet connection or inresponsive server
                    self.errorLabel.text? = "Server not responding or no internet connection"
                    print("server/connection error")
                }
            }
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
