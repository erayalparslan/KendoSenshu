//
//  NewsTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 10/28/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class NewsTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
