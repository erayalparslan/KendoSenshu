//
//  SettingsVC.swift
//  KendoSenshu
//
//  Created by ruroot on 10/23/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var mTableView: UITableView!
    let sectionTitleArray = ["Notifications", "Information"]
    let notificationTitleArray = ["Coming Tournaments",
                                  "Match Results",
                                  "Announcements"]
    let infoTitleArray = [("About", "about"),
                          ("Sign In", "signIn")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
    }
    
    func setDelegates(){
        mTableView.delegate = self
        mTableView.dataSource = self
    }
    
}
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notificationTitleArray.count
        }
        else if section == 1 {
            return infoTitleArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = mTableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableCell
        let cell2 = mTableView.dequeueReusableCell(withIdentifier: "infoCell") as! InfoTableCell
        if indexPath.section == 0 {
           cell1.titleLabel.text = notificationTitleArray[indexPath.row]
            mTableView.allowsSelection = false
           return cell1
        }
        else if indexPath.section == 1 {
            cell2.infoTitleLabel.text = infoTitleArray[indexPath.row].0
            cell2.infoImageView.image = UIImage(named: infoTitleArray[indexPath.row].1)
            mTableView.allowsSelection = true
            return cell2
        }
        return UITableViewCell()
    }
    
    //Custom tableview header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let label = UILabel()
        label.text = sectionTitleArray[section]
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //label.font = UIFont(name: "HelveticaNeue-Light", size: 15)!
        
        label.frame = CGRect(x: 15, y: 2, width: 200, height: 40)
        
        view.addSubview(label)
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mTableView.allowsSelection {
            if indexPath.section == 1 {
                switch indexPath.row {
                case 0:
                    performSegue(withIdentifier: "aboutSegue", sender: nil)
                    break
                case 1:
                    Global.setMainUser(email: "", password: "", isAdmin: false)
                    dismiss(animated: true, completion: nil)
                default:
                    break
                }
            }
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
}
