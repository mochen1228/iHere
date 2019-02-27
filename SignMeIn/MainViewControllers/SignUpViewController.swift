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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var illegalUsernameTextField: UILabel!
    @IBOutlet weak var illegalPasswordTextField: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func onNextButton(_ sender: Any) {
        print("status choice", self.statusChoice)

        // check password illegal
        if !checkPasswordLegal(with: passwordTextField.text!) {
            // Display error texts if user put down a illegal password
            illegalPasswordTextField.text = "Passward must be length 8+ and contain only lowercase letters and numbers"
            return
        } else {
            // In case users corrected their password, remove the error texts
            illegalPasswordTextField.text = ""
        }
        
        // Check email illegal
        if !checkEmailLegal(with: usernameTextField.text!) {
            illegalUsernameTextField.text = "Username already exits"
            return
        } else {
            illegalUsernameTextField.text = ""
            self.performSegue(withIdentifier: "credentialsSuccessSegue", sender: self)
            // Creating the User object
//            var user = PFUser()
//            user.username = usernameTextField.text!
//            user.password = passwordTextField.text!
//            user["status"] = statusChoice
//            user["firstname"] = "Chen"
//            user["lastname"] = "Mo"
//            user["classes"] = []
//
//            user.signUpInBackground { (success, error) in
//                if success {
////                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
//                    print("success")
//                } else {
//                    print("cannot sign up")
//                }
//            }
            
        }
        print("button action finished")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    func checkEmailLegal(with email: String) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

}
