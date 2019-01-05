//
//  RegisterVC.swift
//  KendoSenshu
//
//  Created by ruroot on 10/14/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegisterVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var dojoTF: UITextField!
    @IBOutlet weak var rankTF: UITextField!
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var repass: UITextField!
    var ref: DatabaseReference!
    let iconArray           = ["user", "dojo", "rank", "at", "lock"]
    var dojoArray           = [Dojo]()
    var selectedDojoId      = ""
    var selectedDojo        = String()
    var selectedRank        = String()
    var currentTextField    = UITextField()
    
    
    let rankArray = ["6th Kyu",
                     "5th Kyu",
                     "4th Kyu",
                     "3rd Kyu",
                     "2nd Kyu",
                     "1st Kyu",
                     "1- Shodan",
                     "2- Nidan",
                     "3- Sandan",
                     "4- Yondan",
                     "5- Godan",
                     "6- Rokudan",
                     "7- Nanadan",
                     "8- HachiDan"]
    
    
    let mPicker = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        setDelegates()
        setUI()
        adjustKeyboard()
        loadDojos()
        
    }
    

    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if nameTF.text!.isEmpty || dojoTF.text!.isEmpty ||
           rankTF.text!.isEmpty || mailTF.text!.isEmpty ||
           passTF.text!.isEmpty || repass.text!.isEmpty  {
            ProgressHUD.showError("Fill all the blanks")
        }
        else {
            let mail = mailTF.text!.replacingOccurrences(of: ".", with: ",")
            let pass = passTF.text!
            let rank = rankTF.text!
            let repassword = repass.text!
            let name = nameTF.text!
            
            if !(pass == repassword) {
                ProgressHUD.showError("Passwords do not match")
            }
            else {
                registerNewUser(name, mail, rank, pass)
            }
            
        }
    }
    
    @IBAction func textFieldEditBegin(_ sender: UITextField) {
        currentTextField = sender
    }
    

    
}

extension RegisterVC {
    func setUI(){
        
        nameTF.tag      = 100
        dojoTF.tag      = 101
        rankTF.tag      = 102
        mailTF.tag      = 103
        passTF.tag      = 104
        repass.tag      = 105
        
        setToolbar(nameTF, dojoTF, rankTF, mailTF, passTF, repass)
        
        nameTF.setLeftIcon(UIImage(named: iconArray[0])!)
        dojoTF.setLeftIcon(UIImage(named: iconArray[1])!)
        rankTF.setLeftIcon(UIImage(named: iconArray[2])!)
        mailTF.setLeftIcon(UIImage(named: iconArray[3])!)
        passTF.setLeftIcon(UIImage(named: iconArray[4])!)
        repass.setLeftIcon(UIImage(named: iconArray[4])!)
    }
    
    func setDelegates(){
        nameTF.delegate = self
        dojoTF.delegate = self
        rankTF.delegate = self
        passTF.delegate = self
        repass.delegate = self
        mPicker.delegate = self
        dojoTF.inputView = mPicker
        rankTF.inputView = mPicker
    }
    
    func loadDojos() {
        ref.observe(.value, with: { (snapshot) in
            if snapshot.hasChild("dojos") {
                let enumurator = snapshot.children
                while let result = enumurator.nextObject() as? DataSnapshot {
                    if result.key == "dojos" {
                        let enum2 = result.children
                        while let result2 = enum2.nextObject() as? DataSnapshot {
                            let enum3 = result2.children
                            let tempDojo = Dojo()
                            tempDojo.id = result2.key
                            
                            while let result3 = enum3.nextObject() as? DataSnapshot {
                                if result3.key == "location" {
                                    tempDojo.location = result3.value as! String
                                }
                                else if result3.key == "name" {
                                    tempDojo.name = result3.value as! String
                                }
                                else if result3.key == "yearFounded" {
                                    tempDojo.yearFounded = "\(result3.value as? String  ?? "no_date")"
                                }
                            }
                            self.dojoArray.append(tempDojo)
                        }
                    }
                }
            }
        })
    }
    
    func registerNewUser(_ name: String, _ mail: String, _ rank: String, _ password: String) {
        ref.child("players").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(mail) {
                print("this user already exists")
                ProgressHUD.showError("You are already registered")
            }
            else{
                print("this user can register")
                let details = [
                    "name"    : name,
                    "dojo_id" : self.selectedDojoId,
                    "rank"    : rank,
                    "password": password.md5String
                ]
                let pDetails = ["name" : name,
                                "rank" : rank]
                self.ref.child("players").child(mail).setValue(details)
                self.ref.child("dojos").child(self.selectedDojoId).child("players").child(mail).setValue(pDetails)
                Global.setMainUser(email: mail, password: password.md5String, isAdmin: false)
                Global.isComingFromRegister = true
                self.dismiss(animated: true)
            }
            
        })
    }
    
    func resetFields() {
        self.nameTF.text = ""
        self.dojoTF.text = ""
        self.rankTF.text = ""
        self.mailTF.text = ""
        self.passTF.text = ""
        self.repass.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
                self.view.frame.origin.y -= keyboardSize.height*0.3
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
    
    
    func setToolbar(_ tf1 : UITextField, _ tf2 : UITextField, _ tf3 : UITextField, _ tf4 : UITextField, _ tf5 : UITextField, _ tf6 : UITextField ){
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
        tf4.inputAccessoryView = numberToolbar
        tf5.inputAccessoryView = numberToolbar
        tf6.inputAccessoryView = numberToolbar
        
    }
    
    @objc func cancelPressed() {
        currentTextField.resignFirstResponder()
    }
    @objc func donePressed() {
        
        //dojo
        if currentTextField.tag == 101 {
            currentTextField.text = selectedDojo
        }
        //rank
        else if currentTextField.tag == 102 {
            currentTextField.text = selectedRank
        }
        
        currentTextField.resignFirstResponder()
    }
    
    
    
    
}

extension RegisterVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if dojoTF.isFirstResponder {
            return dojoArray.count
        }
        else if rankTF.isFirstResponder {
            return rankArray.count
        }
        else {
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if dojoTF.isFirstResponder {
           return dojoArray[row].name
        }
        if rankTF.isFirstResponder {
            return rankArray[row]
        }
        else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dojoTF.isFirstResponder {
            self.selectedDojo = dojoArray[row].name
            self.selectedDojoId = "\(dojoArray[row].id)"
        }
        else if rankTF.isFirstResponder {
            self.selectedRank = rankArray[row]
        }
    }
}
