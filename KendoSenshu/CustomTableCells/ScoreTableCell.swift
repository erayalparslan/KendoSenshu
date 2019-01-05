//
//  ScoreTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 10/31/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class ScoreTableCell: UITableViewCell {
    
    @IBOutlet weak var aHitLabel: UILabel!
    @IBOutlet weak var bHitLabel: UILabel!
    @IBOutlet weak var aScoreLabel: UILabel!
    @IBOutlet weak var bScoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
