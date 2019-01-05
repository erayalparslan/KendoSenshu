//
//  DojoPlayerTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 11/19/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class DojoPlayerTableCell: UITableViewCell {
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var customContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
