//
//  DojosVC.swift
//  KendoSenshu
//
//  Created by ruroot on 11/19/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DojosVC: UIViewController {
    @IBOutlet weak var newDojoButton: UIButton!
    @IBOutlet weak var mTableView: UITableView!
    var dojoArray = [Dojo]()
    var ref: DatabaseReference!
    var isOneTimeAnimation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setAdminFeaturesIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadDojos()
    }

    @IBAction func newDojoButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "newDojoSegue", sender: nil)
        Global.isComingFromNewDojo = true
        Global.isComingFromEditDojo = false
    }
    
}

//methods
extension DojosVC {
    func setAdminFeaturesIfNeeded(){
        if Global.getMainUser().2 {
            newDojoButton.alpha = 1
        }
        else {
            newDojoButton.alpha = 0
        }
    }
    
    func setDelegates(){
        mTableView.delegate = self
        mTableView.dataSource = self
        ref = Database.database().reference()
        mTableView.tableFooterView = UIView()
    }
    
    func loadDojos() {
        self.dojoArray.removeAll()
       
        self.ref.child("dojos").observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                for (dojoId, details) in obj {
                    let tmpDojo = Dojo()
                    if let value = details as? NSDictionary {
                        tmpDojo.id              = dojoId                as? String      ?? "no_dojo_id"
                        tmpDojo.name            = value["name"]         as? String      ?? "no_dojo_name"
                        tmpDojo.location        = value["location"]     as? String      ?? "no_dojo_location"
                        tmpDojo.yearFounded     = value["yearFounded"]         as? String      ?? "no_dojo_year"
                    }
                    if self.isUniqueDojo(in: self.dojoArray, at: tmpDojo) {
                        self.dojoArray.append(tmpDojo)
                    }
                }
                self.animateTable()
            }
        })
    }
    
    
    
    func isUniqueDojo(in dojoArray: [Dojo], at item: Dojo) -> Bool {
        for elem in dojoArray {
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
    
    
    func areYouSureAlert(_ indexPath: IndexPath){
        let alert = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.ref.child("dojos").child(self.dojoArray[indexPath.row].id).removeValue()
            self.dojoArray.remove(at: indexPath.row)
            self.mTableView.deleteRows(at: [indexPath], with: .automatic)
            ProgressHUD.showSuccess("Success")
            self.animateTable()
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in })
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    @objc func alertControllerBackgroundTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            Global.selectedDojo = self.dojoArray[indexPath.row]
            Global.isComingFromNewDojo = false
            Global.isComingFromEditDojo = true
            self.performSegue(withIdentifier: "newDojoSegue", sender: nil)
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.backgroundColor =  #colorLiteral(red: 1, green: 0.8392156863, blue: 0.03921568627, alpha: 1)
        return action
    }
    
    @available(iOS 11.0, *)
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.areYouSureAlert(indexPath)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1)
        return action
    }
}

extension DojosVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dojoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = mTableView.dequeueReusableCell(withIdentifier: "Cell") as! DojoTableCell
        let record = self.dojoArray[indexPath.row]
        
        cell.titleLabel.text    = record.name
        cell.locationLabel.text = record.location

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Global.selectedDojo = dojoArray[indexPath.row]
        performSegue(withIdentifier: "dojoSegue", sender: nil)
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
        let edit   = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,edit])
    }
 
}
