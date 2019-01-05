//
//  InfoTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 10/26/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class InfoTableCell: UITableViewCell {
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
