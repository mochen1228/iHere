//
//  InstructorCheckInTableViewCell.swift
//  SignMeIn
//
//  Created by ChenMo on 3/11/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit

class InstructorCheckInTableViewCell: UITableViewCell {

    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentUsernameLabel: UILabel!
    @IBOutlet weak var checkedInTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
