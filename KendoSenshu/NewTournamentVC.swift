//
//  NewTournamentVC.swift
//  KendoSenshu
//
//  Created by ruroot on 11/4/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol mProtocol {
    func getNewTournament(item: Tournament)
    func editTournament(item: Tournament)
}

class NewTournamentVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var mNavigationItem: UINavigationItem!
    
    
    let datePicker = UIDatePicker()
    
    let categoryArray = ["Men", "Women", "Men Team", "Women Team", "Juniors"]
    let sizeArray = [4,8,16,32,64]
    let mPicker = UIPickerView()
    var delegate: mProtocol?
    var record: Tournament? = nil
    let cities = [String](Cities.init().cities.keys).sorted(by: <)
    var ref: DatabaseReference!
    var isOneTimeAnimation = true
    static var selectedRowIndex = Int()
    var currentTextField = UITextField()
    var selectedCategory = String()
    var selectedDate     = String()
    var isDateOkey       = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        adjustKeyboard()
        setDatePicker()
        setUI()
        loadData()
    }
    

    
    
    @IBAction func createBtnPressed(_ sender: UIButton) {
        if nameTF.text!.isEmpty || categoryTF.text!.isEmpty ||
            dateTF.text!.isEmpty || locationTF.text!.isEmpty {
            ProgressHUD.showError("Fill all the blanks")
        }
        else if isDateOkey == false {
            ProgressHUD.showError("Enter a further date")
        }
        else {
            createAlert()
        }
    }
    
    @IBAction func tfEditingBegin(_ sender: UITextField) {
        currentTextField = sender
    }
    
    
    
    
    
}

extension NewTournamentVC {
    
    
    func setToolbar(categoryTextField tf1 : UITextField, dateTextField tf2 : UITextField){
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))]
        numberToolbar.sizeToFit()
        tf1.inputAccessoryView = numberToolbar
        tf2.inputAccessoryView = numberToolbar
    }
    
    @objc func cancelPressed() {
        currentTextField.resignFirstResponder()
    }
    @objc func donePressed() {
        
        if currentTextField.tag == 100 {
            currentTextField.text = selectedCategory
        }
        else if currentTextField.tag == 101 {
            currentTextField.text = selectedDate
            print("date situtation is \(self.isDateOkey)")
        }
        
        currentTextField.resignFirstResponder()
    }
    
    func setDelegates() {
        ref = Database.database().reference()
        nameTF.delegate      = self
        categoryTF.delegate  = self
        dateTF.delegate      = self
        locationTF.delegate  = self
        mPicker.delegate     = self
        mPicker.dataSource   = self
        categoryTF.inputView = mPicker
        categoryTF.tag       = 100
        dateTF.tag           = 101
    }
    func setDatePicker(){
        dateTF.inputView = datePicker
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.locale = Locale(identifier: "tr_TR")
        datePicker.backgroundColor = UIColor.white
        datePicker.layer.cornerRadius = 5.0
        datePicker.layer.shadowOpacity = 0.5
        datePicker.addTarget(self, action: #selector(onDidChangeDate), for: .valueChanged)
    }
    @objc func onDidChangeDate(sender: UIDatePicker){
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "dd/MM/yyyy, HH:mm"
        selectedDate = myDateFormatter.string(from: sender.date)
        
        let userDate = sender.date
        let currDate = Date().addingTimeInterval(259200) //at least 3 days from now
        
        isDateOkey = userDate > currDate
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
    func loadData() {
        if Global.isComingFromEditTournament {
            self.nameTF.text = Global.selectedTournament.name
            self.categoryTF.text = Global.selectedTournament.category
            self.dateTF.text = Global.selectedTournament.date
            self.locationTF.text = Global.selectedTournament.location
        }

    }
    
    func setIcons() {
        nameTF.setLeftIconForLogin(UIImage(named: "name")!)
        categoryTF.setLeftIconForLogin(UIImage(named: "tagBlack")!)
        dateTF.setLeftIconForLogin(UIImage(named: "calendar")!)
        locationTF.setLeftIconForLogin(UIImage(named: "location")!)
    }
    
    func setUI() {
        setToolbar(categoryTextField: categoryTF, dateTextField: dateTF)
        
        if Global.isComingFromNewTournamanet {
            createButton.setTitle("Create", for: .normal)
            mNavigationItem.title = "New Tournament"
        }
        else if Global.isComingFromEditTournament {
            createButton.setTitle("Modify", for: .normal)
            mNavigationItem.title = "Edit Tournament"
            loadData()
        }
//        contentView.addShadow()
        contentView.layer.cornerRadius = 8
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        createButton.layer.cornerRadius = 8
        setIcons()
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.white.cgColor, #colorLiteral(red: 0.1582711935, green: 0.1583048701, blue: 0.1582667232, alpha: 1)]
        
        view.layer.insertSublayer(gradient, at: 0)
    }
}

extension NewTournamentVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if categoryTF.isFirstResponder {
            return categoryArray.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if categoryTF.isFirstResponder {
            return categoryArray[row]
        }
        return "no data"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categoryTF.isFirstResponder {
            self.selectedCategory = categoryArray[row]
        }
    }
    
    func success(){
        ProgressHUD.showSuccess("Success!")
        _ = navigationController?.popViewController(animated: true)
    }
    
    func createAlert(){
        let alert = UIAlertController()
    
        let randomId = "tour\(arc4random_uniform(500))\(arc4random_uniform(600))"
        let name     = self.nameTF.text     ?? ""
        let category = self.categoryTF.text ?? ""
        let date     = self.dateTF.text     ?? ""
        let location = self.locationTF.text ?? ""
        
        let details =
            [
                "name"      : name,
                "category"  : category,
                "date"      : date,
                "location"  : location,
                "isFinished": "no",
                "isGroupStaged" : "no",
                "isStarted" : "no",
                "numberOfFinishedGSM" : 0
            ] as [String : Any]
        
        
        let mString = "Name: \(name)\nCategory: \(category)\nDate: \(date)\nLocation: \(location)"
        let createAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
        if Global.isComingFromNewTournamanet {
            self.ref.child("tournaments").child(randomId).setValue(details)
        }
        else if Global.isComingFromEditTournament {
            self.ref.child("tournaments").child(Global.selectedTournament.id).updateChildValues(details)
        }
        self.success()
        })
        
        
        //close the popup
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in })
        
        
        let messageText = NSMutableAttributedString(
            string: mString,
            attributes: [
                NSAttributedString.Key.paragraphStyle: NSParagraphStyle(),
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        alert.title = "Are you sure?"
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.addAction(cancelAction)
        alert.addAction(createAction)
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

