import UIKit
import Firebase
import FirebaseDatabase

class NewEditDojoVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var mNavigationItem: UINavigationItem!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!

    let datePicker = UIDatePicker()
    let cityPicker = UIPickerView()
    let cities = [String](Cities.init().cities.keys).sorted(by: <)
    var ref: DatabaseReference!
    var selectedDate     = String()
    var selectedLocation = String()
    var currentTextField = UITextField()
    var isDateOkey       = Bool()
    var alertTitle       = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        adjustKeyboard()
        setDatePicker()
        loadData()
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        if nameTF.text!.isEmpty || dateTF.text!.isEmpty || locationTF.text!.isEmpty {
            ProgressHUD.showError("Fill all the blanks")
        }
        else if isDateOkey == false {
            ProgressHUD.showError("Incorrect date")
        }
        else {
            createAlert()
        }
    }
    @IBAction func tfEditBegin(_ sender: UITextField) {
        currentTextField = sender
    }
    
}








extension NewEditDojoVC {
    
    func loadData(){
        if Global.isComingFromEditDojo {
            self.nameTF.text     = Global.selectedDojo.name
            self.dateTF.text     = Global.selectedDojo.yearFounded
            self.locationTF.text = Global.selectedDojo.location
        }
    }
    
    func setDatePicker(){
        dateTF.delegate = self
        locationTF.inputView = cityPicker
        cityPicker.delegate = self
        cityPicker.dataSource = self
        dateTF.inputView = datePicker
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.locale = Locale(identifier: "tr_TR")
        datePicker.backgroundColor = UIColor.white
        datePicker.layer.cornerRadius = 5.0
        datePicker.layer.shadowOpacity = 0.5
        datePicker.addTarget(self, action: #selector(onDidChangeDate), for: .valueChanged)
    }
    
    func setUI() {
        
        dateTF.tag      = 100
        locationTF.tag  = 101
        
        setToolbar(dateTextField: dateTF, locationTextField: locationTF)
        
        ref = Database.database().reference()
        if Global.isComingFromNewDojo {
            createButton.setTitle("Create", for: .normal)
            mNavigationItem.title = "New Dojo"
        }
        else {
            createButton.setTitle("Modify", for: .normal)
            mNavigationItem.title = "Edit Dojo"
            
        }
//        contentView.addShadow()
        contentView.layer.cornerRadius = 8
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        createButton.layer.cornerRadius = 8
        setIcons()
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.white.cgColor, #colorLiteral(red: 0.2050842941, green: 0.2046268582, blue: 0.2054533362, alpha: 1)]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        
        if Global.isComingFromNewDojo {
            self.alertTitle = "New Dojo"
        }
        else if Global.isComingFromEditDojo {
            self.alertTitle = "Edit Dojo"
        }
    }
    
    func setIcons() {
        nameTF.setLeftIconForLogin(UIImage(named: "name")!)
        dateTF.setLeftIconForLogin(UIImage(named: "calendar")!)
        locationTF.setLeftIconForLogin(UIImage(named: "location")!)
    }
    
    @objc func onDidChangeDate(sender: UIDatePicker){
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "dd/MM/yyyy"
        selectedDate = myDateFormatter.string(from: sender.date)
        
        let userDate = sender.date
        let currDate = Date()
        
        isDateOkey = userDate < currDate
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
    
    func createAlert(){
        let alert = UIAlertController()
        let mString = "Name: \(nameTF.text!)\nFoundation: \(dateTF.text!)\nLocation: \(locationTF.text!)"
        let addAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            
            let randomId   = "doj\(arc4random_uniform(500))\(arc4random_uniform(600))"
            let originalId = Global.selectedDojo.id
            let location   = self.locationTF.text ?? "no_location"
            let name       = self.nameTF.text     ?? "no_name"
            let date       = self.dateTF.text     ?? "no_date"
            let details    = ["location" : location, "name" : name, "yearFounded" : date]
            if Global.isComingFromNewDojo {
                self.ref.child("dojos").child(randomId).setValue(details)
                self.alertTitle = "New Dojo"
            }
            else if Global.isComingFromEditDojo {
                self.ref.child("dojos").child(originalId).updateChildValues(details)
                self.alertTitle = "Edit Dojo"
            }
            
            self.success()
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
        alert.title = alertTitle
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
        }
    }
    
    func success(){
        ProgressHUD.showSuccess("Success!")
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    func setToolbar(dateTextField tf1 : UITextField, locationTextField tf2: UITextField){
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
        self.view.endEditing(true)
    }
    @objc func donePressed() {
        if currentTextField.tag == 100 {
            dateTF.text = selectedDate
        }
        else if currentTextField.tag == 101 {
            locationTF.text = selectedLocation
        }
        
        self.view.endEditing(true)
    }
}

extension NewEditDojoVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if locationTF.isFirstResponder {
            return cities.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if locationTF.isFirstResponder {
            return cities[row]
        }
        return "no data"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if locationTF.isFirstResponder {
            selectedLocation = cities[row]
        }
    }
}
