//
//  StudentClassDetailsViewController.swift
//  SignMeIn
//
//  Created by ChenMo on 3/9/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import Parse

class StudentClassDetailsViewController: UIViewController {

    var selectedClass: PFObject? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = selectedClass!["number"] as! String
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
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

extension StudentClassDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    // Extension protocols for table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentClassMapCell", for: indexPath) as! StudentClassMapTableViewCell
        return cell
    }
    
    
}
