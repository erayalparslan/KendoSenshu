//
//  DojoVC.swift
//  KendoSenshu
//
//  Created by ruroot on 11/19/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DojoVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mNavigationItem: UINavigationItem!
    @IBOutlet weak var onImageView: UIView!
    @IBOutlet weak var kendokaCountLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    
    var ref: DatabaseReference!
    var record = Global.selectedDojo
    var players = [Player]()
    var colorFlag = false
    var tmpEmail = ""
    var tmpLose = 0
    var tmpName = ""
    var tmpPass = ""
    var tmpRank = ""
    var tmpWin = 0
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setUI()
        loadPlayers()
    }

}



//=============================================================================================================================================
//=============================================================================================================================================
//                                                              Methods
//=============================================================================================================================================
//=============================================================================================================================================

extension DojoVC {
    func setDelegates() {
        mTableView.delegate   = self
        mTableView.dataSource = self
        ref = Database.database().reference()
        mTableView.tableFooterView = UIView()
    }
    
    func setUI() {
        locationLabel.text    = record.location
        mNavigationItem.title = record.name
        onImageView.layer.cornerRadius = self.onImageView.frame.size.width / 2
        onImageView.clipsToBounds = true
        onImageView.layer.borderColor  = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        onImageView.layer.borderWidth  = 2
        headerView.dropShadow()
    }
    
    func loadPlayers() {
        ref.child("dojos").child("\(Global.selectedDojo.id)").child("players").observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                for (email, value) in obj {
                    let tmpPlayer = Player()
                    if let obj2 = value as? NSDictionary {
                        tmpPlayer.email         = email             as? String ?? "no_player_mail"
                        tmpPlayer.name          = obj2["name"]      as? String ?? "no_player_name"
                        tmpPlayer.stats.rank    = obj2["rank"]      as? String ?? "no_player_rank"
                        tmpPlayer.dojoId        = Global.selectedDojo.id
                    }
                    if self.isUniquePlayer(in: self.players, at: tmpPlayer) {
                        self.players.append(tmpPlayer)
                    }
                }
                self.kendokaCountLabel.text = "\(self.players.count) Kendo Senshu"
                self.animateTableView()
            }
        })
    }
    
    func isUniquePlayer(in playerArray: [Player], at item: Player) -> Bool {
        for elem in playerArray {
            if elem.email == item.email {
                return false
            }
        }
        return true
    }
    
    func animateTableView() {
        self.mTableView.reloadData()
        let fadeAnimation = TableViewAnimation.Cell.fade(duration: 0.5)
        self.mTableView.animate(animation: fadeAnimation)
    }
}


























//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UITableView Delegates
//=============================================================================================================================================
//=============================================================================================================================================

extension DojoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = mTableView.dequeueReusableCell(withIdentifier: "Cell") as! DojoPlayerTableCell
        let record = players[indexPath.row]
        
        cell.nameLabel.text = record.name
        cell.rankLabel.text = record.stats.rank
        
        if colorFlag {
            cell.customContentView.backgroundColor = #colorLiteral(red: 0.9357605577, green: 0.9408621788, blue: 0.953433454, alpha: 1)
            colorFlag = false
        }
        else {
            cell.customContentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            colorFlag = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("player selected")
        Global.selectedPlayer = players[indexPath.row]
        performSegue(withIdentifier: "playerSegue", sender: nil)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            // moved to top
            UIView.animate(withDuration: 0.3) {
                self.headerViewTopConstraint.constant = -40
                self.headerView.alpha = 0.8
                self.view.layoutIfNeeded()
            }
            
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            // moved to bottom
            UIView.animate(withDuration: 0.3) {
                self.headerViewTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else {
            // didn't move
        }
    }
}




//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UIView Extension
//=============================================================================================================================================
//=============================================================================================================================================

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
