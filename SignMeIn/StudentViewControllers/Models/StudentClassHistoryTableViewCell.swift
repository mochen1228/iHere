//
//  StudentClassHistoryTableViewCell.swift
//  SignMeIn
//
//  Created by ChenMo on 3/13/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit

class StudentClassHistoryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var checkinTimeLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
