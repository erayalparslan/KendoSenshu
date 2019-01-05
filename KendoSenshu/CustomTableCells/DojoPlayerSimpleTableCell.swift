//
//  DojoPlayerSimpleTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 12/8/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class DojoPlayerSimpleTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
