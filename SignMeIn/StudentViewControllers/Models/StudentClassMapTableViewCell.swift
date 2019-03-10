//
//  StudentClassMapTableViewCell.swift
//  SignMeIn
//
//  Created by ChenMo on 3/9/19.
//  Copyright © 2019 ChenMo. All rights reserved.
//

import UIKit
import MapKit

class StudentClassMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
