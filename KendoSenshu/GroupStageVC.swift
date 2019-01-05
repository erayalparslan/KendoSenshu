//
//  GroupStageVC.swift
//  KendoSenshu
//
//  Created by ruroot on 12/8/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class GroupStageVC: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mSegmentedControlTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mDialog: UIView!
    @IBOutlet weak var mDialogBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var aWinnerButton: UIButton!
    @IBOutlet weak var bWinnerButton: UIButton!
    @IBOutlet weak var aWinnerButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bWinnerButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mScoreView: UIView!
    @IBOutlet weak var mScoreViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mDialogHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mContentView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var aWinnerLabel: UILabel!
    @IBOutlet weak var aScoreTextField: UITextField!
    @IBOutlet weak var bWinnerLabel: UILabel!
    @IBOutlet weak var bScoreTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationTextField: UITextField!
    
    var ref: DatabaseReference!
    var groupNames                  = [String]()
    var players                     = [Player]()
    var groups                      = [[Player]]()
    var headersWithGroups           = [(String, [Player])]()
    var headersWithEmails           = [(String, [String])]()
    var lastContentOffset: CGFloat  = 0.0
    var groupStageItems             = [(String, [String:String])]()
    var groupStageModel             = [GroupStageModel]()
    var customPlayers               = [CustomPlayer]()
    var isWinnerSelected            = false
    var curentTextField             = UITextField()
    var mPickerView                 = UIPickerView()
    var minutes                     = 0
    var seconds                     = 0
    var points                      = 0
    var finalDuration               = String()
    var areMatchesSaved             = Bool()
    var matchesArray                = [Match]()
    var selectedMatchIndexPath      = IndexPath()
    var aScoreInt                   = 0
    var bScoreInt                   = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        initializeComponents()
        adjustKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        loadData()
        setUI()
    }
    
    
    
    @IBAction func textFieldEditingBegin(_ sender: UITextField) {
        self.curentTextField = sender
    }
    
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        self.animateTableView()
    }
    
    @IBAction func playerButtonPressed(_ sender: UIButton) {
        //if player is not selected, select and show scoreView
        if isWinnerSelected == false {
            if sender.tag      == 100 {
                selectFirstPlayer()
            }
            else if sender.tag == 101 {
                selectSecondPlayer()
            }
            resetTextFields()
            showScoreView()
            isWinnerSelected = true
        }
            
        //if player is selected, deselect it and hide scoreView
        else {
            deselectPlayers()
            hideScoreView()
            isWinnerSelected = false
        }
    }
    
    func getNumberOfAvailableGSM(callback: @escaping (_ numberOfAvailableGSM: Int?)->Void) {
        var numberOfKids = Int()
        self.ref.child("tournaments").child(Global.selectedTournament.id).child("group_stage_matches").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            numberOfKids = Int(snapshot.childrenCount)
            callback(numberOfKids)
        })
    }

    func getNumberOfFinishedGSM(callback: @escaping (_ success: Bool,_ numberOfFinishedMatches: Int?)->Void) {
        var numberOfFinishedMatches = Int()
        self.ref.child("tournaments").child(Global.selectedTournament.id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let details = snapshot.value as? NSDictionary {
                numberOfFinishedMatches = details["numberOfFinishedGSM"] as? Int ?? 0
                callback(true, numberOfFinishedMatches)
            }
            else {
                callback(false, nil)
            }
        })
    }
    
    func incrementNumberOfFinishedGSM(callback: @escaping (_ success: Bool, _ numberOfFinishedGSM: Int?)->Void) {
        getNumberOfFinishedGSM { (success, numberOfFinishedMatches) in
            if let numberOfFinishedMatches = numberOfFinishedMatches, success == true{
                let mData = ["numberOfFinishedGSM" : numberOfFinishedMatches + 1]
                self.ref.child("tournaments").child(Global.selectedTournament.id).updateChildValues(mData) { (error, ref) in
                    if (error == nil){
                        
                        callback(true, numberOfFinishedMatches + 1)
                    }
                    else {
                        
                        callback(false, nil)
                    }
                }
            }
            
        }
        

       
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("save button pressed")
        if isWinnerSelected == false {
            ProgressHUD.showError("Winner is not selected")
        }
        else if aScoreTextField.text!.isEmpty || bScoreTextField.text!.isEmpty || durationTextField.text!.isEmpty {
            ProgressHUD.showError("Fill the blanks")
        }
        else {
            saveMatchScoreInDatabase { (success) in
                if success {
                    print("match score is saved in the db")
                    
                    
                    self.incrementNumberOfFinishedGSM(callback: { (success, numberOfFinishedGSM) in
                        if let numberOfFinishedGSM = numberOfFinishedGSM, success == true{
                            print("Number of finished gsm is inceremented. current is \(numberOfFinishedGSM)")
                            
                            
                            self.getNumberOfAvailableGSM(callback: { (numberOfTotalMatch) in
                                if let numberOfTotalMatch = numberOfTotalMatch {
                                    if numberOfFinishedGSM == numberOfTotalMatch {
                                        print("all matches are finished")
                                    }
                                    else {
                                        print("matches are not completed yet")
                                    }
                                }
                            })
                        }
                        else {
                            print("Number of finished gsm could not be incremented")
                        }
                    })
                    
                    
                }
                else {
                    print("match score is not saved in the db")
                }
            }
            
            updateTotalScoreInDatabase { (success) in
                if success {
                    self.getGroupStageFromDatabase { (result) in
                        if result {
                            print("group stage is taken from the db")
                        }
                    }
                }
            }
            
            
            
            self.getGroupMatchesFromDatabase(callback: { (result) in
                if result == true {
                    self.mTableView.reloadData()
                    ProgressHUD.showSuccess("Saved")
                    self.hideDialog()
                    print("group matches are fetched from the db")
                }
                else {
                    print("group matches could not be fetched from the db")
                }
            })
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hideDialog()
    }
    
}















//=============================================================================================================================================
//=============================================================================================================================================
//                                                                 Methods
//=============================================================================================================================================
//=============================================================================================================================================

extension GroupStageVC {
    
    
    func setUI() {
        cancelButton.layer.cornerRadius = 5
        saveButton.layer.cornerRadius   = 5
        aWinnerButton.layer.cornerRadius = 8
        aWinnerButton.layer.borderWidth  = 2
        aWinnerButton.layer.borderColor  = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bWinnerButton.layer.cornerRadius = 8
        bWinnerButton.layer.borderWidth  = 2
        bWinnerButton.layer.borderColor  = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mDialogHeightConstraint.constant = 270
        aWinnerButtonTopConstraint.constant = 45
        bWinnerButtonTopConstraint.constant = 100
        setToolbar(aScoreTextField, bScoreTextField, durationTextField)
    }
    
    func saveMatchScoreInDatabase(callback: @escaping (Bool)->Void) {
        let selectedMatchId = matchesInSection(atIndex: selectedMatchIndexPath.section)[selectedMatchIndexPath.row].matchId
        let mDetails = ["isFinished" : "yes",
                        "scoreA"     : aScoreInt,
                        "scoreB"     : bScoreInt,
                        "averageA"   : getAverage(winPoint: aScoreInt, losePoint: bScoreInt),
                        "averageB"   : getAverage(winPoint: bScoreInt, losePoint: aScoreInt),
                        "duration"   : self.durationTextField.text ?? "no_duration"
            ] as [String : Any]
        
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").child(selectedMatchId).updateChildValues(mDetails) { (error, ref) in
            if (error == nil){
                callback(true)
            }
            else {
                callback(false)
            }
        }
    }
    
    func getCurrentScoreOfPlayer(playerMail mail : String, callback: @escaping (_ aCurrentScore: Int, _ currentAverage: Int)->Void) {
        var currentScore    = 0
        var currentAverage  = 0
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage").child(mail).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let details = snapshot.value as? NSDictionary {
                currentScore    = details["score"] as? Int ?? 0
                currentAverage  = details["avg"]   as? Int ?? 0
            }
            callback(currentScore, currentAverage)
        })
    }
    
    
    func updateScoreA(callback: @escaping (Bool)->Void) {
        let aEmail = matchesInSection(atIndex: selectedMatchIndexPath.section)[selectedMatchIndexPath.row].aEmail
        getCurrentScoreOfPlayer(playerMail: aEmail) { (preScore, preAverage) in
            let finalScore = self.aScoreInt + preScore
            let finalAverage    = self.getAverage(winPoint: self.aScoreInt, losePoint: self.bScoreInt) + preAverage
            self.updateScore(playerMail: aEmail, finalScore: finalScore, finalAverage: finalAverage, callback: { (result) in
                if result == true {
                    print("scoreA is updated successfully")
                    callback(true)
                }
                else {
                    print("scoreA could not be updated")
                    callback(false)
                }
            })
        }
    }
    
    func updateScoreB(callback: @escaping (Bool)->Void) {
        let bEmail = matchesInSection(atIndex: selectedMatchIndexPath.section)[selectedMatchIndexPath.row].bEmail
        getCurrentScoreOfPlayer(playerMail: bEmail) { (preScore, preAverage) in
            let finalScore      = self.bScoreInt + preScore
            let finalAverage    = self.getAverage(winPoint: self.bScoreInt, losePoint: self.aScoreInt) + preAverage
            self.updateScore(playerMail: bEmail, finalScore: finalScore, finalAverage: finalAverage, callback: { (result) in
                if result == true {
                    print("scoreB is updated successfully")
                    callback(true)
                }
                else {
                    print("scoreB could not be updated")
                    callback(false)
                }
            })
        }
    }
    
    func updateTotalScoreInDatabase(callback: @escaping (Bool)->Void) {
        updateScoreA { (success) in
            if success {
                self.updateScoreB(callback: { (success) in
                    if success {
                        callback(true)
                    }
                })
            }
        }
    }
    
    
    func updateScore(playerMail mail : String, finalScore score: Int, finalAverage average: Int, callback: @escaping (_ result: Bool)->Void) {
        let mData = ["score" : score,
                     "avg"   : average]
        self.ref.child("tournaments").child(Global.selectedTournament.id).child("group_stage").child(mail).updateChildValues(mData, withCompletionBlock: {error, ref in
            if error != nil{
                print("ERROR")
                callback(false)
            }
            else{
                print("ok")
                callback(true)
            }
        })
    }
    
    func deselectPlayers() {
        UIView.animate(withDuration: 0.35) {
            self.aWinnerButtonTopConstraint.constant = 45
            self.bWinnerButtonTopConstraint.constant = 100
            self.aWinnerButton.alpha                 = 1.0
            self.bWinnerButton.alpha                 = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    func setDelegates() {
        aScoreTextField.delegate    = self
        bScoreTextField.delegate    = self
        durationTextField.delegate  = self
        mTableView.delegate         = self
        mTableView.dataSource       = self
        ref                         = Database.database().reference()
        aScoreTextField.inputView   = mPickerView
        bScoreTextField.inputView   = mPickerView
        durationTextField.inputView = mPickerView
        mPickerView.delegate        = self
        mPickerView.dataSource      = self
    }
    
    func selectFirstPlayer() {
        UIView.animate(withDuration: 0.35) {
            self.aWinnerButtonTopConstraint.constant = 15
            self.bWinnerButtonTopConstraint.constant = 15
            self.bWinnerButton.alpha                 = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func selectSecondPlayer() {
        UIView.animate(withDuration: 0.35) {
            self.aWinnerButtonTopConstraint.constant = 15
            self.bWinnerButtonTopConstraint.constant = 15
            self.aWinnerButton.alpha                 = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func showScoreView() {
        UIView.animate(withDuration: 0.5) {
            self.mDialogHeightConstraint.constant = 370
            self.mScoreViewTopConstraint.constant = 90.0
            self.mScoreView.alpha                 = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    func hideScoreView() {
        UIView.animate(withDuration: 0.5) {
            self.mDialogHeightConstraint.constant = 270
            self.mScoreViewTopConstraint.constant = -20.0
            self.mScoreView.alpha                 = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    
    func initializeComponents(){
        mDialogBottomConstraint.constant =  -mDialog.frame.height - 5;
        mDialog.layer.cornerRadius = 8
        mScoreView.alpha = 0.0
        mContentView.layer.cornerRadius = 8
        cancelButton.layer.cornerRadius = 8
        saveButton.layer.cornerRadius   = 8
        cancelView.layer.cornerRadius   = 8
        saveView.layer.cornerRadius     = 8
        self.view.layoutIfNeeded()
        aWinnerButton.tag = 100
        bWinnerButton.tag = 101
        aScoreTextField.tag   = 200
        bScoreTextField.tag   = 201
        durationTextField.tag = 202
    }
    
    
    
    func groupStageInfo(callback: @escaping (Bool)->Void) {
        var isStarted = ""
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let details = snapshot.value as? NSDictionary {
                isStarted = details["isGroupStaged"] as? String ?? "no_group_stage_info"
                if isStarted == "yes" {
                    callback(true)
                }
                else {
                    callback(false)
                }
            }
        })
    }
    
    func groupMatchesInfo(callback: @escaping (Bool)->Void) {
        var isStarted = ""
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let details = snapshot.value as? NSDictionary {
                isStarted = details["isGroupMatched"] as? String ?? "no_group_match_start_info"
                if isStarted == "yes" {
                    callback(true)
                }
                else {
                    callback(false)
                }
            }
        })
    }
    
    
    func loadData() {
        groupStageInfo { (result) in
            if result == true {
                self.getGroupStageFromDatabase(callback: { (result) in
                    if result == true {
                        print("group stage is taken from the db")
                        self.animateTableView()
                        
                        self.groupMatchesInfo(callback: { (result) in
                            if result == true {
                                self.getGroupMatchesFromDatabase(callback: { (result) in
                                    if result == true {
                                        self.animateTableView()
                                        print("group matches are fetched from the db")
                                    }
                                    else {
                                        print("group matches could not be fetched from the db")
                                    }
                                })
                            }
                        })
                    }
                    else {
                        print("group stage could not be taken from the db")
                    }
                })
            }
            else {
                self.setGroupStage()
                self.saveGroupStageInDatabase(callback: { (result) in
                    if result == true {
                        print("group stage is saved in the db")
                        let mData  = ["isGroupStaged"  : "yes"]
                        let mData2 = ["isGroupMatched" : "yes"]
                        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").updateChildValues(mData, withCompletionBlock: { (error, ref) in
                            if error == nil {
                                print(" :::isGroupStaged = yes:::   in the db")
                                
                                //get data from the db
                                self.getGroupStageFromDatabase(callback: { (result) in
                                    if result == true {
                                        print("group stage is taken from the db")
                                        self.animateTableView()
                                        
                                        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").updateChildValues(mData2, withCompletionBlock: { (error, ref) in
                                            if error == nil {
                                                print(" :::isGroupMatched = yes:::   in the db")
                                                self.saveGroupMatchesInDatabase(callback: { (result) in
                                                    if result == true {
                                                        print("group matches are saved in the db")
        
                                                        self.getGroupMatchesFromDatabase(callback: { (result) in
                                                            if result == true {
                                                                self.animateTableView()
                                                                print("group matches are fetched from the db")
                                                            }
                                                            else {
                                                                print("group matches could not be fetched from the db")
                                                            }
                                                        })
                                                    }
                                                    else {
                                                        print("group matches could not be saved in the db")
                                                    }
                                                })
                                            }
                                        })

                                    }
                                    else {
                                        print("group stage could not be taken from the db")
                                    }
                                })
                            }
                        })
                    }
                    else {
                        print("group stage could not be saved in the db")
                    }
                })
            }
        }
    }
    
    func getGroupMatchesFromDatabase(callback: @escaping (Bool)->Void) {
        self.matchesArray.removeAll()
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                for (matchId, value) in obj {
                    let tmpMatch = Match()
                    if let obj2 = value as? NSDictionary {
                        tmpMatch.matchId    = matchId               as? String ?? "no_match_id"
                        tmpMatch.playerA    = obj2["playerA"]       as? String ?? "no_playerA"
                        tmpMatch.playerB    = obj2["playerB"]       as? String ?? "no_playerB"
                        tmpMatch.groupName  = obj2["groupName"]     as? String ?? "no_group_name"
                        tmpMatch.isFinished = obj2["isFinished"]    as? String ?? "no_isFinished_value"
                        tmpMatch.duration   = obj2["duration"]      as? String ?? "no_duration_value"
                        tmpMatch.aEmail     = obj2["aEmail"]        as? String ?? "no_a_email"
                        tmpMatch.bEmail     = obj2["bEmail"]        as? String ?? "no_b_email"
                        tmpMatch.scoreA     = obj2["scoreA"]        as? Int    ?? 0
                        tmpMatch.scoreB     = obj2["scoreB"]        as? Int    ?? 0
                    }
                    if self.isUniqueMatch(in: self.matchesArray, at: tmpMatch) {
                        self.matchesArray.append(tmpMatch)
                    }
                }
            }
            callback(true)
        })
        
    }

    
    func isUniqueMatch(in matches: [Match], at item: Match) -> Bool {
        for elem in matches {
            if elem.matchId == item.matchId {
                return false
            }
        }
        return true
    }
    
    func numberOfItems(inSectionIndex index: Int) -> Int {
        return playersInSection(atIndex: index).count
    }
    
    func numberOfMatchedItems(inSectionIndex index: Int) -> Int {
        return matchedPlayersInSection(atIndex: index).count
    }
    
    func numberOfSections() -> Int {
        return self.groupNames.count
    }
    
    func getSectionLabel(inSectionIndex index: Int) -> String {
        return self.groupNames[index]
    }
    
    
    func saveGroupStageInDatabase(callback: @escaping (Bool)->Void)  {
        let myGroup = DispatchGroup()
        for player in self.customPlayers {
            myGroup.enter()
            let details = ["name" : player.name, "group" :  player.group]
            self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage").child("\(player.email)").setValue(details) { (error, dbReference) in
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            callback(true)
        }
    }
    
    func playersInSection(atIndex index: Int) -> [CustomPlayer] {
        let item = self.groupNames[index]
        
        let filteredPlayers = self.customPlayers.filter { (customPlayer: CustomPlayer) -> Bool in
            return customPlayer.group == item
        }
        return filteredPlayers
    }
    
    
    func matchesInSection(atIndex index: Int) -> [Match] {
        let item = self.groupNames[index]
        
        let filteredMatches = self.matchesArray.filter { (myMatch: Match) -> Bool in
            return myMatch.groupName == item
        }
        return filteredMatches
    }
    

    
    func matchedPlayersInSection(atIndex index: Int) -> [(String, String)] {
        let internalPlayers = playersInSection(atIndex: index)
        var matchesTuple = [(String, String)]()
        
        if internalPlayers.count == 3 {
            matchesTuple.append((internalPlayers[0].name, internalPlayers[1].name))
            matchesTuple.append((internalPlayers[1].name, internalPlayers[2].name))
            matchesTuple.append((internalPlayers[2].name, internalPlayers[0].name))
        }
        else if internalPlayers.count == 4 {
            matchesTuple.append((internalPlayers[3].name, internalPlayers[1].name))
            matchesTuple.append((internalPlayers[2].name, internalPlayers[0].name))
            matchesTuple.append((internalPlayers[1].name, internalPlayers[2].name))
            matchesTuple.append((internalPlayers[0].name, internalPlayers[1].name))
            matchesTuple.append((internalPlayers[3].name, internalPlayers[0].name))
            matchesTuple.append((internalPlayers[2].name, internalPlayers[3].name))
        }
        
        return matchesTuple
    }
    

    
    
    
    
    func saveGroupMatchesInDatabase(callback: @escaping (Bool)->Void)  {
        for sectionIndex in (0..<self.groupNames.count) {
            
            let internalPlayers = playersInSection(atIndex: sectionIndex)
            if internalPlayers.count == 3 {
                
                let match1  = ["isFinished" : "no",
                              "playerA"    : internalPlayers[0].name,
                              "playerB"    : internalPlayers[1].name,
                              "groupName"  : internalPlayers[0].group,
                              "aEmail"     : internalPlayers[0].email,
                              "bEmail"     : internalPlayers[1].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match1)
                
                
                
                let match2  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[1].name,
                               "playerB"    : internalPlayers[2].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[1].email,
                               "bEmail"     : internalPlayers[2].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match2)
                
                
                
                let match3  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[2].name,
                               "playerB"    : internalPlayers[0].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[2].email,
                               "bEmail"     : internalPlayers[0].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match3)
                
            }
            
            if internalPlayers.count == 4 {
                let match1  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[3].name,
                               "playerB"    : internalPlayers[1].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[3].email,
                               "bEmail"     : internalPlayers[1].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match1)
                
                
                
                let match2  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[2].name,
                               "playerB"    : internalPlayers[0].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[2].email,
                               "bEmail"     : internalPlayers[0].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match2)
                
                
                
                let match3  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[1].name,
                               "playerB"    : internalPlayers[2].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[1].email,
                               "bEmail"     : internalPlayers[2].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match3)
                
                let match4  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[0].name,
                               "playerB"    : internalPlayers[1].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[0].email,
                               "bEmail"     : internalPlayers[1].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match4)
                
                
                
                let match5  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[3].name,
                               "playerB"    : internalPlayers[0].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[3].email,
                               "bEmail"     : internalPlayers[0].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match5)
                
                
                
                let match6  = ["isFinished" : "no",
                               "playerA"    : internalPlayers[2].name,
                               "playerB"    : internalPlayers[3].name,
                               "groupName"  : internalPlayers[0].group,
                               "aEmail"     : internalPlayers[2].email,
                               "bEmail"     : internalPlayers[3].email]
                self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage_matches").childByAutoId().setValue(match6)
                
            }
        }
        callback(true)
    }
    
    
    
    func getGroupStageFromDatabase(callback: @escaping (Bool)->Void) {
        self.customPlayers.removeAll()
        var tmpCustomPlayers = [CustomPlayer]()
        self.ref.child("tournaments").child("\(Global.selectedTournament.id)").child("group_stage").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let details = snapshot.value as? NSDictionary {
                print("\n\n")
                for (email, playerDetails) in details {
                    let tmpEmail = email as? String ?? "no_email"
                    if let tmp = playerDetails as? NSDictionary {
                        let tmpName  = tmp["name"] as? String  ?? "no_name_sorry"
                        let tmpGroup = tmp["group"] as? String ?? "no_group_sorry"
                        let tmpScore = tmp["score"] as? Int ?? 0
                        let tmpAvg   = tmp["avg"]   as? Int ?? 0
                        if !self.groupNames.contains(tmpGroup) {
                            self.groupNames.append(tmpGroup)
                            self.groupNames = self.groupNames.sorted(by: {( item1, item2 ) -> Bool in
                                return item1.compare(item2) == ComparisonResult.orderedAscending
                            })
                        }
                        let customPlayer = CustomPlayer()
                        customPlayer.email = tmpEmail
                        customPlayer.name  = tmpName
                        customPlayer.group = tmpGroup
                        customPlayer.point = tmpScore
                        customPlayer.avg   = tmpAvg
                        tmpCustomPlayers.append(customPlayer)
                        self.customPlayers = tmpCustomPlayers.sorted(by: {( item1, item2 ) -> Bool in
                            return item1.group.compare(item2.group) == ComparisonResult.orderedAscending
                        })
                    }
                }
            }
            callback(true)
        })
    }
    
    
    func animateTableView() {
        self.mTableView.reloadData()
        let fadeAnimation = TableViewAnimation.Cell.fade(duration: 0.5)
        self.mTableView.animate(animation: fadeAnimation)
    }
    
    
    func setToolbar(_ tf1 : UITextField, _ tf2 : UITextField, _ tf3 : UITextField){
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))]
        numberToolbar.sizeToFit()
        tf1.inputAccessoryView = numberToolbar
        tf2.inputAccessoryView = numberToolbar
        tf3.inputAccessoryView = numberToolbar
    }
    
    
    @objc func cancelPressed() {
        curentTextField.resignFirstResponder()
    }
    @objc func donePressed() {
        if curentTextField.tag == 200 {
            curentTextField.text   = "\(points) points"
            self.aScoreInt = points
        }
        else if curentTextField.tag == 201 {
            curentTextField.text   = "\(points) points"
            self.bScoreInt = points
        }
        else if curentTextField.tag == 202 {
            curentTextField.text = "\(minutes) m, \(seconds) s"
        }
        curentTextField.resignFirstResponder()
    }
    
    
    func setGroupStage() {
        while players.isEmpty == false {
            if players.count % 3 == 0 {
                let randomThree = players.randomElements(number: 3)
                groups.append(randomThree)
                for j in 0..<3 {
                    players.removeAll(where: {$0.email == randomThree[j].email})
                }
            }
            else if players.count % 3 == 1 || players.count % 3 == 2 {
                let randomFour = players.randomElements(number: 4)
                groups.append(randomFour)
                for j in 0..<4 {
                    players.removeAll(where: {$0.email == randomFour[j].email})
                }
            }
            let tmpGroupName = getGroupName(withGroupCount: groups.count)
            groupNames.append(tmpGroupName)
        }

        
        //  debugMembers(groups: groups)
        fillCustomplayers()
    }
    
    
    func debugMembers(groups: [[Player]]) {
        print("\n\n")
        var jkk = 0
        for group in groups {
            print("\(groupNames[jkk]) has \(group.count) members within it: \n------------------------\n")
            for item in group {
                print("player email is: \(item.email)")
            }
            print("\n")
            jkk += 1
        }
    }
    
    func fillCustomplayers(){
        customPlayers.removeAll()
        var i = 0
        for groupName in groupNames {
            for j in groups[i].indices {
                let customPlayer = CustomPlayer()
                customPlayer.email = groups[i][j].email
                customPlayer.name  = groups[i][j].name
                customPlayer.group = groupName
                customPlayers.append(customPlayer)
            }
            i += 1
        }
    }
    
    func showDialog(atIndexPath indexPath: IndexPath){
        mTableView.isUserInteractionEnabled         = false
        mSegmentedControl.isUserInteractionEnabled  = false
        
        let playerA = matchesInSection(atIndex: indexPath.section)[indexPath.row].playerA
        let playerB = matchesInSection(atIndex: indexPath.section)[indexPath.row].playerB
        
        self.selectedMatchIndexPath = indexPath
        
        aWinnerButton.setTitle(playerA, for: UIControl.State.normal)
        bWinnerButton.setTitle(playerB, for: UIControl.State.normal)
        aWinnerLabel.text   = playerA
        bWinnerLabel.text   = playerB
        
        
        UIView.animate(withDuration: 0.2) {
            self.mTableView.alpha                 = 0.4
            self.segmentView.alpha                = 0.4
            self.mDialogBottomConstraint.constant = 5
            self.mDialog.alpha                    = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDialog(){
        mTableView.isUserInteractionEnabled         = true
        mSegmentedControl.isUserInteractionEnabled  = true
        UIView.animate(withDuration: 0.2) {
            self.mTableView.alpha                 = 1.0
            self.segmentView.alpha                = 1.0
            self.mDialogBottomConstraint.constant = -self.mDialog.frame.height - 5
            self.mDialog.alpha                    = 0.6
            self.view.layoutIfNeeded()
        }
        deselectPlayers()
        hideScoreView()
        resetTextFields()
    }
    
    func resetTextFields() {
        aScoreTextField.text    = ""
        bScoreTextField.text    = ""
        durationTextField.text  = ""
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func adjustKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height*0.45
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    
    func getAverage(winPoint win: Int, losePoint lose: Int) -> Int {
        return win - lose
    }

    
    func showWarningIfNeeded(){
        let val = Global.getGroupStageWarning()
        if val == false {
            ProgressHUD.showSuccess("Disqualify one kendoka from each group")
            Global.setGroupStageWarning(to: true)
        }
    }
    
    func getGroupName(withGroupCount groupCount: Int) -> String {
        if groupCount == 1 {
            return "Group A"
        }
        else if groupCount == 2 {
            return "Group B"
        }
        else if groupCount == 3 {
            return "Group C"
        }
        else if groupCount == 4 {
            return "Group D"
        }
        else if groupCount == 5 {
            return "Group E"
        }
        else if groupCount == 6 {
            return "Group F"
        }
        else if groupCount == 7 {
            return "Group G"
        }
        else if groupCount == 8 {
            return "Group H"
        }
        else if groupCount == 9 {
            return "Group I"
        }
        else if groupCount == 10 {
            return "Group J"
        }
        else if groupCount == 11 {
            return "Group K"
        }
        else if groupCount == 12 {
            return "Group L"
        }
        else if groupCount == 13 {
            return "Group M"
        }
        else if groupCount == 14 {
            return "Group N"
        }
        else if groupCount == 15 {
            return "Group O"
        }
        else if groupCount == 16 {
            return "Group P"
        }
        else if groupCount == 17 {
            return "Group R"
        }
        else if groupCount == 18 {
            return "Group S"
        }
        else if groupCount == 19 {
            return "Group T"
        }
        else if groupCount == 20 {
            return "Group U"
        }
        return ""
    }
    
}



















//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UITableView Delegates
//=============================================================================================================================================
//=============================================================================================================================================




extension GroupStageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mSegmentedControl.selectedSegmentIndex == 0 {
            return self.numberOfItems(inSectionIndex: section)
        }
        else if mSegmentedControl.selectedSegmentIndex == 1 {
            return matchesInSection(atIndex: section).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellSimple = mTableView.dequeueReusableCell(withIdentifier: "Cell")       as! DojoPlayerSimpleTableCell
        let cellVersus = mTableView.dequeueReusableCell(withIdentifier: "versusCell") as! VersusTableViewCell
        if mSegmentedControl.selectedSegmentIndex == 0 {
            cellSimple.nameLabel.text       = self.playersInSection(atIndex: indexPath.section)[indexPath.row].name
            cellSimple.scoreLabel.text      = "\(self.playersInSection(atIndex: indexPath.section)[indexPath.row].point)"
            cellSimple.averageLabel.text    = "\(self.playersInSection(atIndex: indexPath.section)[indexPath.row].avg)"
            return cellSimple
        }
        else if mSegmentedControl.selectedSegmentIndex == 1 {
            let playerA                     = matchesInSection(atIndex: indexPath.section)[indexPath.row].playerA
            let playerB                     = matchesInSection(atIndex: indexPath.section)[indexPath.row].playerB
            let isFinished                  = matchesInSection(atIndex: indexPath.section)[indexPath.row].isFinished
            
            cellVersus.aPlayerLabel.text    = playerA
            cellVersus.bPlayerLabel.text    = playerB
            
            if isFinished == "yes" {
                cellVersus.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                
            }
            else {
                cellVersus.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            }
            
            return cellVersus
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8901320147)
        let label = UILabel()
        label.text = self.getSectionLabel(inSectionIndex: section)
        
        label.font = UIFont(name: "Charter-Roman", size: 15)!
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        label.frame = CGRect(x: 45, y: -1, width: 200, height: 35)
        
        let image = UIImageView(image: UIImage(named: "groupIcon"))
        image.frame = CGRect(x: 20, y: 7, width: 20, height: 20)
        view.addSubview(label)
        view.addSubview(image)
        return view
    }
    
    func setSelectedPlayerInfo(atIndexPath indexPath: IndexPath) {
        let tmpEmail = self.playersInSection(atIndex: indexPath.section)[indexPath.row].email
        let tmpPlayer : Player = Player()
        self.ref.child("players").child(tmpEmail).observe(.value, with: { (snapshot) in
            if let obj = snapshot.value as? NSDictionary {
                tmpPlayer.email         = tmpEmail
                tmpPlayer.dojoId        = obj["dojo_id"]  as? String ?? "no_dojo_id"
                tmpPlayer.name          = obj["name"]     as? String ?? "no_name"
                tmpPlayer.password      = obj["password"] as? String ?? "no_pass"
                tmpPlayer.stats.rank    = obj["rank"]     as? String ?? "no_rank"
                Global.selectedPlayer   = tmpPlayer
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mSegmentedControl.selectedSegmentIndex == 0 {
            setSelectedPlayerInfo(atIndexPath: indexPath)
            performSegue(withIdentifier: "profileSegue", sender: nil)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            UIView.animate(withDuration: 0.3) {
                self.mSegmentedControlTopConstraint.constant = -44
                self.mSegmentedControl.alpha = 0
                self.view.layoutIfNeeded()
            }
            
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            UIView.animate(withDuration: 0.3) {
                self.mSegmentedControlTopConstraint.constant = 5
                self.mSegmentedControl.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else {
            // didn't move
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Global.getMainUser().2 && mSegmentedControl.selectedSegmentIndex == 1 && matchesInSection(atIndex: indexPath.section)[indexPath.row].isFinished != "yes"{
            return true
        }
        return false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let finishAction = mAlertAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [finishAction])
    }
    
    @available(iOS 11.0, *)
    func mAlertAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Finish") { (action, view, completion) in
            self.showDialog(atIndexPath: indexPath)
            completion(false)
        }
        action.image = UIImage(named: "finishIcon")
        action.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return action
    }

}



















//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UIPickerView Delegates
//=============================================================================================================================================
//=============================================================================================================================================


extension GroupStageVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if aScoreTextField.isFirstResponder || bScoreTextField.isFirstResponder {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if aScoreTextField.isFirstResponder || bScoreTextField.isFirstResponder {
            return 3
        }
        else {
            switch component {
                case 0:
                    return 3
                case 1:
                    return 60
                default:
                    return 0
            } //switch
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if aScoreTextField.isFirstResponder || bScoreTextField.isFirstResponder {
            return "\(row) Points"
        }
        switch component {
            case 0:
                return "\(row) Minutes"
            
            case 1:
                return "\(row) Seconds"
            default:
                return ""
        } //switch
            
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if aScoreTextField.isFirstResponder || bScoreTextField.isFirstResponder {
            points = row
        }
        else {
            switch component {
                case 0:
                    minutes = row
                case 1:
                    seconds = row
                default:
                    break
            }
        }
    }
}




//=============================================================================================================================================
//=============================================================================================================================================
//                                                            Other Extensions
//=============================================================================================================================================
//=============================================================================================================================================


extension Array {
    func randomElements(number: Int) -> [Player] {
        guard number > 0 else { return [Player]() }
        var remaining = self
        var chosen = [Player]()
        for _ in 0 ..< number {
            guard !remaining.isEmpty else { break }
            let randomIndex = Int(arc4random_uniform(UInt32(remaining.count)))
            chosen.append(remaining[randomIndex] as! Player)
            remaining.remove(at: randomIndex)
        }
        return chosen
    }
}

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.bounds.contains(point) ? self : nil
    }
    func blink(enabled: Bool = true, duration: CFTimeInterval = 1.0, stopAfter: CFTimeInterval = 0.0 ) {
        enabled ? (UIView.animate(withDuration: duration, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.6 },
            completion: { [weak self] _ in self?.alpha = 1 })) : self.layer.removeAllAnimations()
        if !stopAfter.isEqual(to: 0.0) && enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
                self?.layer.removeAllAnimations()
            }
        }
    }
}
