//
//  ChooseStatusViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 2/26/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit

class ChooseStatusViewController: UIViewController {
    // This view controller will give the users the option fo choose
    // if they are student or instructor. This information will carry
    // on to the next VC and will determine what type of account to
    // be created.

    // "Student" or "Instructor", depends on which button click
    var currentStatusChoice = ""
    
    @IBOutlet weak var roundedStudentButton: UIButton!
    
    @IBOutlet weak var roundedInstructorButton: UIButton!
    
    @IBAction func onStudentButton(_ sender: Any) {
        currentStatusChoice = "Student"
        self.performSegue(withIdentifier: "selectedStatusSegue", sender: self)
    }
    
    @IBAction func onInstructorButton(_ sender: Any) {
        currentStatusChoice = "Instructor"
        self.performSegue(withIdentifier: "selectedStatusSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedStatusSegue" {
            let secondViewController: SignUpViewController = segue.destination as! SignUpViewController
            secondViewController.statusChoice = currentStatusChoice
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  rounding out the edges higher num more round
        roundedStudentButton.layer.cornerRadius = 25
        roundedInstructorButton.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
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
