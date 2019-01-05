//
//  MatchTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 10/28/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class MatchTableCell: UITableViewCell {
    @IBOutlet weak var aPlayerLabel: UILabel!
    @IBOutlet weak var bPlayerLabel: UILabel!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var fieldView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftView.layer.borderWidth = 0.5
        leftView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        rightView.layer.borderWidth = 0.5
        rightView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
