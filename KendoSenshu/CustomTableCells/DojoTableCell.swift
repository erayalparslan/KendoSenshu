//
//  DojoTableCell.swift
//  KendoSenshu
//
//  Created by ruroot on 11/19/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class DojoTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mCustomView: UIView!
    @IBOutlet weak var CustomContentView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUI() {
       
        
        
        mCustomView.layer.shadowColor = UIColor.black.cgColor
        mCustomView.layer.shadowOpacity = 0.85
        mCustomView.layer.shadowOffset = CGSize.zero
        mCustomView.layer.shadowRadius = 5
        
        
    }

}
