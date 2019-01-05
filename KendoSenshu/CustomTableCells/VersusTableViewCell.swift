//
//  VersusTableViewCell.swift
//  KendoSenshu
//
//  Created by ruroot on 12/17/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class VersusTableViewCell: UITableViewCell {

    @IBOutlet weak var aPlayerLabel: UILabel!
    @IBOutlet weak var bPlayerLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    var isFinished = Bool()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
