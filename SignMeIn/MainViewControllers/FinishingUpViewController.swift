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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var userdata: [String: String] = [:]

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    
    @IBAction func onSignUpButton(_ sender: Any) {
        var user = PFUser()
        user.username = userdata["username"]
        user.password = userdata["password"]
        user["status"] = userdata["status"]
        user["firstname"] = firstnameTextField.text!
        user["lastname"] = lastnameTextField.text!
        user["classes"] = []

        user.signUpInBackground { (success, error) in
            if success {
    //                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                print("sign up success")
            } else {
                print("cannot sign up")
            }
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
