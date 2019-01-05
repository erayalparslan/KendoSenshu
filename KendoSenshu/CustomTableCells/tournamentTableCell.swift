//
//  tournamentTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 10/24/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class tournamentTableCell: UITableViewCell {
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        customContentView.layer.shadowColor = UIColor.black.cgColor
        customContentView.layer.shadowOpacity = 0.85
        customContentView.layer.shadowOffset = CGSize.zero
        customContentView.layer.shadowRadius = 4.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
