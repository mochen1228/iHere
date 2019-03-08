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

class InstructorAddClassViewController: UIViewController, AddLocationViewControllerDelegate {
    func finishPassing(location: MKPlacemark) {
        print("Received:")
        print(location)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddLocationViewController {
            destination.delegate = self
        }
    }
    
    @IBAction func onPickLocationButton(_ sender: Any) {
        performSegue(withIdentifier: "showMapSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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



