//
//  ProfileVC.swift
//  KendoSenshu
//
//  Created by ruroot on 11/8/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProfileVC: UIViewController {
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dojoLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var lastPlaceLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    @IBOutlet weak var masteryLabel: UILabel!
    var ref: DatabaseReference!
    var mDojo   = Dojo()
    var mPlayer = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        setUI()
        resetFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getDojoInfo()
        getPlayerInfo { (Player) in
            self.displayInfo()
        }
        
    }
    
    
    
    
    
    //=============================================================================================================================================
    //=============================================================================================================================================
    //                                                                Methods
    //=============================================================================================================================================
    //=============================================================================================================================================
    
    func resetFields(){
        self.nameLabel.text         = ""
        self.dojoLabel.text         = ""
        self.ageLabel.text          = ""
        self.rankLabel.text         = ""
        self.lastPlaceLabel.text    = ""
        self.winLabel.text          = ""
        self.loseLabel.text         = ""
        self.masteryLabel.text      = ""
        self.nameLabel.alpha        = 0.0
        self.dojoLabel.alpha        = 0.0
        self.ageLabel.alpha         = 0.0
        self.rankLabel.alpha        = 0.0
        self.lastPlaceLabel.alpha   = 0.0
        self.winLabel.alpha         = 0.0
        self.loseLabel.alpha        = 0.0
        self.masteryLabel.alpha     = 0.0
    }
    
    
    func setUI() {
        mImageView.layer.cornerRadius = self.mImageView.frame.size.width / 2
        mImageView.clipsToBounds = true
        mImageView.layer.borderColor  = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mImageView.layer.borderWidth  = 1.2
    }
    
    func getDojoInfo() {
        ref.child("dojos").child(Global.selectedPlayer.dojoId).observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                self.mDojo.id       = Global.selectedPlayer.dojoId
                self.mDojo.name     = obj["name"] as? String ?? "no_dojo_name"
            }
        })
    }
    
    func getPlayerInfo(completion: @escaping (_ mPlayer: Player) -> Void) {
        ref.child("players").child(Global.selectedPlayer.email).observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                self.mPlayer.dojoId             = obj["dojo_id"]    as? String ?? "-"
                self.mPlayer.name               = obj["name"]       as? String ?? "-"
                self.mPlayer.stats.age          = obj["age"]        as? Int    ?? 0
                self.mPlayer.stats.rank         = obj["rank"]       as? String ?? "-"
                self.mPlayer.stats.lastPlace    = obj["last_place"] as? String ?? "-"
                self.mPlayer.stats.win          = obj["win"]        as? Int    ?? 0
                self.mPlayer.stats.lose         = obj["lose"]       as? Int    ?? 0
                self.mPlayer.stats.mastery      = obj["mastery"]    as? String ?? "-"
            }
            completion(self.mPlayer)
        })
    }
    
    func displayInfo() {
        UIView.animate(withDuration: 0.2) {
            self.dojoLabel.text         = self.mDojo.name
            self.nameLabel.text         = self.mPlayer.name
            self.ageLabel.text          = "\(self.mPlayer.stats.age)"
            self.rankLabel.text         = self.mPlayer.stats.rank
            self.lastPlaceLabel.text    = self.mPlayer.stats.lastPlace
            self.winLabel.text          = "\(self.mPlayer.stats.win)"
            self.loseLabel.text         = "\(self.mPlayer.stats.lose)"
            self.masteryLabel.text      = self.mPlayer.stats.mastery
            self.dojoLabel.alpha        = 1.0
            self.nameLabel.alpha        = 1.0
            self.ageLabel.alpha         = 1.0
            self.rankLabel.alpha        = 1.0
            self.lastPlaceLabel.alpha   = 1.0
            self.winLabel.alpha         = 1.0
            self.loseLabel.alpha        = 1.0
            self.masteryLabel.alpha     = 1.0
            self.view.layoutIfNeeded()
        }
    }


}
