//
//  StartTournamentVC.swift
//  KendoSenshu
//
//  Created by ruroot on 11/5/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class StartTournamentVC: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    
    var record: Tournament? = nil
    var players = [Player]()
    var selectedPlayerIndexPathRow = 0
    var colorFlag = false
    var isUser = false
    var ref: DatabaseReference!
    var isOneTimeAniamtion = true
    var isTournamentStarted = "no"
    var lastContentOffset: CGFloat = 0
    var tmpMails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setUIDesign()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getTournamentStartInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fillMails()
        displayInformation()
        loadPlayers()
        setStartButton()
    }
    

    
    @IBAction func startPressed(_ sender: UIButton) {
        if self.isTournamentStarted == "no" {
            //check if admin...
            if Global.getMainUser().2 == true {
                self.startButton.alpha = 1
                startButton.setImage(UIImage(named: "start"), for: UIControl.State.normal)
                startAlert()
            }
                
            //check if player...
            else if Global.getMainUser().0.isEmpty == false && Global.getMainUser().1.isEmpty == false && Global.getMainUser().2 == false {
                self.startButton.alpha = 1
                startButton.setImage(UIImage(named: "attend"), for: UIControl.State.normal)
                joinAlert()
            }
            //check if visitor
            else {
                self.startButton.alpha = 0
            }
        }
        else if self.isTournamentStarted == "yes" {
            self.startButton.alpha = 1
            startButton.setImage(UIImage(named: "continue"), for: UIControl.State.normal)
            performSegue(withIdentifier: "startSegue", sender: nil)
        }
    }
    
    

}


//=============================================================================================================================================
//=============================================================================================================================================
//                                                                 Methods
//=============================================================================================================================================
//=============================================================================================================================================


extension StartTournamentVC {
    
    func displayInformation() {
        UIView.animate(withDuration: 0.3) {
            self.navigationItem.title = Global.selectedTournament.name
            self.categoryLabel.text   = Global.selectedTournament.category
            self.dateLabel.text       = Global.selectedTournament.date
            self.locationLabel.text   = Global.selectedTournament.location
            self.playerCountLabel.text = "\(self.players.count)"
            self.categoryLabel.alpha    = 1
            self.dateLabel.alpha        = 1
            self.locationLabel.alpha    = 1
            self.playerCountLabel.alpha = 1
            self.startButton.alpha      = 1
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startSegue" {
            let vc = segue.destination as! GroupStageVC
            vc.players = self.players
        }
    }
    
    func getTournamentStartInfo(){
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").observe(.value, with: { (snapshot) in
            if let details = snapshot.value as? NSDictionary {
                self.isTournamentStarted = details["isStarted"] as? String ?? "shit"
            }
        })
    }
    
    func setStartButton(){
        if self.isTournamentStarted == "no" {
            //check if admin...
            if Global.getMainUser().2 == true {
                self.startButton.alpha = 1
                startButton.setImage(UIImage(named: "start"), for: UIControl.State.normal)
            }
            //check if player...
            else if Global.getMainUser().0.isEmpty == false && Global.getMainUser().1.isEmpty == false && Global.getMainUser().2 == false {
                self.startButton.alpha = 1
                startButton.setImage(UIImage(named: "attend"), for: UIControl.State.normal)
            }
            //check if visitor
            else {
                self.startButton.alpha = 0
            }
        }
        else if self.isTournamentStarted == "yes" {
            startButton.setImage(UIImage(named: "continue"), for: UIControl.State.normal)
        }
    }
    
    
    func isUniquePlayer(in playerArray: [Player], at item: Player) -> Bool {
        for elem in playerArray {
            if elem.email == item.email || item.email == ""{
                return false
            }
        }
        return true
    }
    
    func setDelegates() {
        mTableView.delegate = self
        mTableView.dataSource = self
        ref = Database.database().reference()
    }
    
    func loadPlayers() {
        self.players.removeAll()
        ref.child("tournaments").child("\(Global.selectedTournament.id)").child("before_tournaments").child("players").observe(.value, with: { (snapshot) in
            let enumurator = snapshot.children
            while let result = enumurator.nextObject() as? DataSnapshot {
                
                //search result.key in the players table and get their full detail
                self.ref.child("players").child("\(result.key)").observe(.value, with: { (snapshot) in
                    let myEnum = snapshot.children
                    var tmpDojoID = ""
                    var tmpName   = ""
                    var tmpPass   = ""
                    var tmpRank   = ""
                    let tmpPlayer = Player()
                    while let myResult = myEnum.nextObject() as? DataSnapshot {
                        if myResult.key == "dojo_id" {
                            tmpDojoID = myResult.value as? String ?? ""
                        }
                        else if myResult.key == "name" {
                            tmpName   = myResult.value as? String ?? ""
                        }
                        else if myResult.key == "password" {
                            tmpPass   = myResult.value as? String ?? ""
                        }
                        else if myResult.key == "rank" {
                            tmpRank   = myResult.value as? String ?? ""
                        }
                    }
                    
                    tmpPlayer.dojoId        = tmpDojoID
                    tmpPlayer.email         = result.key
                    tmpPlayer.name          = tmpName
                    tmpPlayer.password      = tmpPass
                    tmpPlayer.stats.rank    = tmpRank
                    
                    //only add unique players
                    if self.isUniquePlayer(in: self.players, at: tmpPlayer) {
                        self.players.append(tmpPlayer)
                        self.playerCountLabel.text = "\(self.players.count)"
                    }
                    self.animateTableView()
                })
                
            }
        })
    }
    
    func setUIDesign() {
        startButton.layer.cornerRadius = startButton.frame.height/2
        startButton.layer.borderColor  = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        startButton.layer.borderWidth  = 1
        headerView.layer.borderColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        startButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        headerView.layer.borderWidth   = 0.8
        headerView.layer.cornerRadius  = 10
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.8
        headerView.layer.shadowOffset = CGSize.zero
        headerView.layer.shadowRadius = 6
        
        startButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        // Shadow and Radius
        startButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        startButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        startButton.layer.shadowOpacity = 1.0
        startButton.layer.shadowRadius = 0.0
        startButton.layer.masksToBounds = false
        
        resetFields()
        mTableView.tableFooterView = UIView()
    }
    
    func resetFields() {
        navigationItem.title        = ""
        categoryLabel.text          = ""
        dateLabel.text              = ""
        locationLabel.text          = ""
        playerCountLabel.text       = ""
        self.categoryLabel.alpha    = 0
        self.dateLabel.alpha        = 0
        self.locationLabel.alpha    = 0
        self.playerCountLabel.alpha = 0
        self.startButton.alpha      = 0
    }
    
    @available(iOS 11.0, *)
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.deleteAlert(at: indexPath)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        return action
    }
    
    
    func success(){
        ProgressHUD.showSuccess("Success!")
        _ = navigationController?.popViewController(animated: true)
    }
    
    func deleteAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            let tourId    = Global.selectedTournament.id
            let playerId  = self.players[indexPath.row].email
            self.ref.child("tournaments").child("\(tourId)").child("before_tournaments").child("players").child("\(playerId)").removeValue()
            self.loadPlayers()
            ProgressHUD.showSuccess("Success")

        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            //do nothing
        })
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    func startAlert(){
        let alert = UIAlertController()
        let mString = "Category: \(categoryLabel.text!)\nDate: \(dateLabel.text!)\nLocation: \(locationLabel.text!)\nKendokas: \(playerCountLabel.text!)"
        let createAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            if (self.players.count <= 3) {
                ProgressHUD.showError("Number of players is too low")
            }
            else {
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("isStarted").setValue("yes")
                ProgressHUD.showSuccess("Tournament started")
                self.performSegue(withIdentifier: "startSegue", sender: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            //just close the alert popup
        })
        
        
        let messageText = NSMutableAttributedString(
            string: mString,
            attributes: [
                NSAttributedString.Key.paragraphStyle: NSParagraphStyle(),
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        alert.title = "Start the tournament"
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
        }
    }
    
    
    func fillMails() {
        self.tmpMails.removeAll()
        ref.child("tournaments").child(Global.selectedTournament.id).child("before_tournaments").child("players").observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                for (key, _) in obj {
                    let tmpMail = key as? String ?? "no_email"
                    self.tmpMails.append(tmpMail)
                }
            }
        })
    }
    
    
    func joinAlert(){
        let alert = UIAlertController()
        let mString = "Category: \(categoryLabel.text!)\nDate: \(dateLabel.text!)\nLocation: \(locationLabel.text!)\n"
        let createAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            if self.tmpMails.contains(Global.getMainUser().0) {
                print("already registered")
            }
            else {
                let mDetails = ["\(Global.getMainUser().0)" : "dummyvalueee"]
                self.ref.child("tournaments").child(Global.selectedTournament.id).child("before_tournaments").child("players").updateChildValues(mDetails)
                ProgressHUD.showSuccess("Registered to \(Global.selectedTournament.name)")
                self.animateTableView()
                self.tmpMails.append(Global.getMainUser().0)
            }
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            //just close the alert popup
        })
        
        
        let messageText = NSMutableAttributedString(
            string: mString,
            attributes: [
                NSAttributedString.Key.paragraphStyle: NSParagraphStyle(),
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        alert.title = "Join \(record?.name ?? "the tournament")"
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
        }
    }
}


//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UITableView Delegates
//=============================================================================================================================================
//=============================================================================================================================================


extension StartTournamentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell   = mTableView.dequeueReusableCell(withIdentifier: "Cell") as! DojoPlayerTableCell
        let record = players[indexPath.row]
        
        cell.nameLabel.text = record.name
        cell.rankLabel.text = record.stats.rank
        
        if colorFlag {
            cell.customContentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            colorFlag = false
        }
        else {
            cell.customContentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            colorFlag = true
        }

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func animateTableView() {
        self.mTableView.reloadData()
        let fadeAnimation = TableViewAnimation.Cell.fade(duration: 0.5)
        self.mTableView.animate(animation: fadeAnimation)
        self.isOneTimeAniamtion = false
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.selectedPlayer = players[indexPath.row]
        performSegue(withIdentifier: "playerSegue", sender: nil)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Global.getMainUser().2 {
            return true
        }
        return false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            // moved to top
            UIView.animate(withDuration: 0.3) {
                self.headerViewTopConstraint.constant = -40
                self.headerView.alpha = 0.6
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
