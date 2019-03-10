//
//  SignUpViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 2/26/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    // This VC will get the email and password from user input and
    // attempt to sign up
    
    let passwordChars = "qwertyuiopasdfghjklzxcvbnm1234567890"
    var statusChoice = ""
    @IBOutlet weak var roundedNextButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var illegalUsernameTextField: UILabel!
    @IBOutlet weak var illegalPasswordTextField: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func onNextButton(_ sender: Any) {
        // Check if the credentials are legal, and move on to the "finishing up"
        //      controller
        // ATTENTION:
        // This button action will only pass the credentials to the segue, it
        //      will NOT create a user yet
        print("status choice", self.statusChoice)
        var usernameLegal = true
        var passwordLegal = true
        // check password illegal
        if !checkPasswordLegal(with: passwordTextField.text!) {
            // Display error texts if user put down a illegal password
            illegalPasswordTextField.text = "must only contain lowercase letters and numbers and be 8+ characters"
            passwordLegal = false
        } else {
            // In case users corrected their password, remove the error texts
            illegalPasswordTextField.text = ""
        }
        
        // Check email illegal
        if !checkUsernameLegal(with: usernameTextField.text!) {
            print("illegal")
            illegalUsernameTextField.text = "Username already exits"
            usernameLegal = false
        } else {
            illegalUsernameTextField.text = ""
        }
        if usernameLegal == false || passwordLegal == false {
            return
        } else {
            self.performSegue(withIdentifier: "credentialsSuccessSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
        roundedNextButton.layer.cornerRadius = 25
    }
    
    func checkPasswordLegal(with password: String) -> Bool {
        // For the first prototype version, the application would only
        // allow lower case letters and numbers
        // The length of the password has to be 8 or +
        for i in password {
            if !passwordChars.contains(i) {
                return false
            }
        }
        return password.count > 7
    }
    
    func checkUsernameLegal(with email: String) -> Bool {
        // TODO:
        // Implement the feature that allows the error textfield to display
        //      which type of illegal is the username/password
        
        // if email.count < 8 {
            // return false
        // }
        
        // For querying users, use "_User", or it won't work
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo:usernameTextField.text!)
        var legal = true
        
        // CAUSION:
        // This code will throw error when the user database has NO users at all
        // Currently working on solutions, but having at least 1 user in the
        //      database will hide this problem temporarily
        // TODO: Make the query work when querying an empty database
        let count = try! query.findObjects().count
        return count == 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass on the credentials to the "finishing up" screen
        // For now, a new users has NOT been created yet
        if segue.identifier == "credentialsSuccessSegue" {
            let userdata = ["username": usernameTextField.text!,
                            "password": passwordTextField.text!,
                            "status": statusChoice]
            let secondViewController: FinishingUpViewController = segue.destination as! FinishingUpViewController
            secondViewController.userdata = userdata
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
