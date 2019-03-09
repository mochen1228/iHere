//
//  InstructorClassTableViewCell.swift
//  SignMeIn
//
//  Created by ChenMo on 3/8/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit

class InstructorClassTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNumberLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseLocationLabel: UILabel!
    @IBOutlet weak var courseInstructorLabel: UILabel!
    @IBOutlet weak var courseTimeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
