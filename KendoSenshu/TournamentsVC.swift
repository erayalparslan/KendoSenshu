//
//  Tournaments.swift
//  KendoSenshu
//
//  Created by ruroot on 10/23/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TournamentsVC: UIViewController {
    @IBOutlet weak var mSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addButtonWidthConstraint: NSLayoutConstraint!
    
    var tournaments = [Tournament]()
    var filteredTournaments = [Tournament]()
    var selectedTournamentIndexPathRow = 0
    var tempItem : Tournament? = nil
    var ref: DatabaseReference!
    var isWelcomed = false
    var isOneTimeAnimation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegatesAndFirebase()
        setAdminFeaturesIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        welcomeUser()
        loadTournaments()
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        Global.isComingFromEditTournament = false
        Global.isComingFromNewTournamanet = true
        performSegue(withIdentifier: "editSegue", sender: nil)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        filteredTournaments = tournamentsInSegment(indexInSegmentedControl: mSegmentedControl.selectedSegmentIndex)
        mTableView.reloadData()
        if mSegmentedControl.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.32) {
                self.addButtonHeightConstraint.constant = 60.0
                self.addButtonWidthConstraint.constant  = 60.0
                if Global.getMainUser().2 {
                    self.addButton.alpha = 1.0
                }
                else {
                    self.addButton.alpha = 0.0
                }
                self.view.layoutIfNeeded()
            }
        }
        else if mSegmentedControl.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.32) {
                self.addButtonHeightConstraint.constant = 20.0
                self.addButtonWidthConstraint.constant  = 20.0
                self.addButton.alpha = 0.0
                self.view.layoutIfNeeded()
            }
        }
        
    }

}


//=============================================================================================================================================
//=============================================================================================================================================
//                                                              Methods
//=============================================================================================================================================
//=============================================================================================================================================

extension TournamentsVC {
    
    func welcomeUser(){
        if self.isWelcomed == false && Global.getMainUser().0.isEmpty == false{
            ref.child("players").child(Global.getMainUser().0).observe(.value, with: { (snapshot) in
                if let details = snapshot.value as? NSDictionary {
                    ProgressHUD.showSuccess("Welcome \(details["name"] as? String ?? "kendoka")")
                    self.isWelcomed = true
                }
            })
        }
    }
    
    func loadTournaments() {
        self.tournaments.removeAll()
        ref.child("tournaments").observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                for (tournamentId, details) in obj {
                    let tmpTournament = Tournament()
                    
                    if let value = details as? NSDictionary {
                        tmpTournament.id        = tournamentId          as? String    ?? "no_tour_id"
                        tmpTournament.name      = value["name"]         as? String    ?? "no_tour_name"
                        tmpTournament.category  = value["category"]     as? String    ?? "no_category"
                        tmpTournament.date      = value["date"]         as? String    ?? "no_date"
                        tmpTournament.location  = value["location"]     as? String    ?? "no_location"
                        tmpTournament.isEnded   = value["isFinished"]   as? String    ?? "no"
                    }
                    if self.isUniqueTournament(in: self.tournaments, at: tmpTournament) {
                        self.tournaments.append(tmpTournament)
                    }
                    self.filteredTournaments = self.tournamentsInSegment(indexInSegmentedControl: self.mSegmentedControl.selectedSegmentIndex)
                    
                }
                self.animateTable()
            }
        })
    }
    func setDelegatesAndFirebase(){
        mTableView.delegate = self
        mTableView.dataSource = self
        ref = Database.database().reference()
        mTableView.tableFooterView = UIView()
    }
    
    func setAdminFeaturesIfNeeded() {
        if !Global.getMainUser().2 {
            addButton.alpha = 0
        }
    }
    
    
    func tournamentsInSegment(indexInSegmentedControl index: Int) -> [Tournament] {
        var flag = String()
        if index == 0 {
            flag = "no"
        }
        else if index == 1{
            flag = "yes"
        }
        let filteredTournaments = tournaments.filter { (tournament: Tournament) -> Bool in
            tournament.isEnded == flag
        }
        return filteredTournaments
    }
    
    func isUniqueTournament(in tournamentArray: [Tournament], at item: Tournament) -> Bool {
        for elem in tournamentArray {
            if elem.id == item.id {
                return false
            }
        }
        return true
    }
    func animateTable() {
        mTableView.reloadData()
        
        if isOneTimeAnimation {
            let cells = mTableView.visibleCells
            let tableHeight: CGFloat = mTableView.bounds.size.height
            for i in cells {
                let cell: UITableViewCell = i as UITableViewCell
                cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            }
            var index = 0
            for a in cells {
                let cell: UITableViewCell = a as UITableViewCell
                UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0);
                }, completion: nil)
                index += 1
            }
            isOneTimeAnimation = false
        }
    }
    
    func mAlert(_ indexPath: IndexPath){
        let alert = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            let childId = self.filteredTournaments[indexPath.row].id
            self.ref.child("tournaments").child("\(childId)").removeValue()
            self.loadTournaments()
            ProgressHUD.showSuccess("Success")
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            //just close the alert popup
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
}


//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UITableView Delegates
//=============================================================================================================================================
//=============================================================================================================================================

extension TournamentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return filteredTournaments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "Cell") as! tournamentTableCell
        let record = filteredTournaments[indexPath.row]
        
        cell.titleLabel.text    = record.name
        cell.locationLabel.text = record.location
        cell.dateLabel.text     = String(record.date.prefix(10))
        cell.categoryLabel.text = record.category
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.selectedTournament = filteredTournaments[indexPath.row]
        Global.isComingFromEditTournament = false
        Global.isComingFromNewTournamanet = true
        performSegue(withIdentifier: "beforeStartSegue", sender: nil)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Global.getMainUser().2 && mSegmentedControl.selectedSegmentIndex == 0 {
            return true
        }
        return false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit   = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
    
    @available(iOS 11.0, *)
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            Global.selectedTournament = self.filteredTournaments[indexPath.row]
            Global.isComingFromEditTournament = true
            Global.isComingFromNewTournamanet = false
            self.performSegue(withIdentifier: "editSegue", sender: nil)
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.backgroundColor =  #colorLiteral(red: 1, green: 0.8392156863, blue: 0.03921568627, alpha: 1)
        return action
    }
    
    @available(iOS 11.0, *)
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.mAlert(indexPath)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1)
        return action
    }
}
