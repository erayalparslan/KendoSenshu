//
//  ViewController.swift
//  KendoSenshu
//
//  Created by ruroot on 10/13/18.
//  Copyright © 2018 Eray Alparslan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var stackcenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var credStackView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var viewcenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
    var ref: DatabaseReference!
    
    var mFlag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegatesAndFirebase()
        adjustKeyboard()
        tryAutoLogin()
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        print("register pressed")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Global.isComingFromRegister == true{
            tryAutoLogin()
        }
    }

    
    @IBAction func loginPressed(_ sender: UIButton) {
        let email = self.emailTF.text!.replacingOccurrences(of: ".", with: ",")
        let password = self.passwordTF.text!.md5String
        let buttonTitle = self.loginButton.titleLabel?.text ?? ""
        
        setAnimatedLogin(titleForButton: buttonTitle, emailAsUsername: email, andPassword: password)
    }
    

    
    @IBAction func guestPressed(_ sender: UIButton) {
        Global.setMainUser(email: "", password: "", isAdmin: false)
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
}








//=============================================================================================================================================
//=============================================================================================================================================
//                                                                   Methods
//=============================================================================================================================================
//=============================================================================================================================================

extension ViewController {
    
    func tryAutoLogin() {
        let mailUD = Global.getMainUser().0
        let passUD = Global.getMainUser().1
        
        if ( !(mailUD.isEmpty || passUD.isEmpty) ){
            login(mailUD, passUD)
        }
    }
    
    
    func setDelegatesAndFirebase(){
        emailTF.delegate = self
        passwordTF.delegate = self
        ref = Database.database().reference()
    }
    
    func setUI(){
        registerButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerButton.layer.borderWidth = 1.1
        registerButton.layer.cornerRadius = 6
        credStackView.alpha = 0
        setIcons()
    }
    
    func setIcons(){
        emailTF.setLeftIconForLogin(UIImage(named: "user")!)
        passwordTF.setLeftIconForLogin(UIImage(named: "lock")!)
    }
    
    func setAnimatedLogin(titleForButton title: String, emailAsUsername email: String, andPassword password: String) {
        if title == "Sign In" {
            UIView.animate(withDuration: 0.5) {
                self.viewcenterYConstraint.constant = 65
                self.stackcenterYConstraint.constant = -65
                self.credStackView.alpha = 1
                self.logoBottomConstraint.constant = 55
                self.view.layoutIfNeeded()
            }
            self.loginButton.setTitle("Login", for: UIControl.State.normal)
        }
        else if title == "Login" {
            if email.isEmpty || password.isEmpty {
                UIView.animate(withDuration: 0.5) {
                    self.viewcenterYConstraint.constant = 0
                    self.stackcenterYConstraint.constant = 0
                    self.credStackView.alpha = 0
                    self.logoBottomConstraint.constant = 40
                    self.view.endEditing(true)
                    self.view.layoutIfNeeded()
                }
                self.loginButton.setTitle("Sign In", for: UIControl.State.normal)
            }
            else {
                login(email, password)
            }
        }
    }
    
    func login(_ email: String, _ password: String) {
        ProgressHUD.show()
        ref.child("players").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(email) {
                self.ref.child("players").child(email).observe(.value, with: { (snapshot) in
                    if let details = snapshot.value as? NSDictionary {
                        if let db_password = details["password"] as? String {
                            if db_password == password{
                                if let isAdmin = details["isAdmin"] as? Int {
                                    if isAdmin == 1 {
                                        //login success and he is the admin
                                        Global.setMainUser(email: email, password: password, isAdmin: true)
                                        
                                    }
                                    else {
                                        //login success but he is NOT the admin
                                        Global.setMainUser(email: email, password: password, isAdmin: false)
                                    }
                                }
                                else {
                                    Global.setMainUser(email: email, password: password, isAdmin: false)
                                }
                                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                                ProgressHUD.dismiss()
                            }
                            else {
                                ProgressHUD.showError("Wrong password")
                            }
                        }
                    }
                })
            }
            else {
                ProgressHUD.showError("Wrong credentials")
            }
        })
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
                self.logoBottomConstraint.constant = 40
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
                self.logoBottomConstraint.constant = 40
            }
        }
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        
        if mFlag {
            mFlag = false
        mImageView.image = UIImage(named: "garu")
        }
        else{
            mFlag = true
            mImageView.image = UIImage(named: "mainLogo")
        }
    }
    
    
    @IBAction func unwindToLogin(_segue: UIStoryboardSegue){}
}



//=============================================================================================================================================
//=============================================================================================================================================
//                                                            UITextField Extension
//=============================================================================================================================================
//=============================================================================================================================================

extension UITextField {
    /// set icon of 20x20 with left padding of 8px
    func setLeftIcon(_ icon: UIImage) {
        
        let padding = 5
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 12, width: 35, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    func setLeftIconForLogin(_ icon: UIImage) {
        
        let padding = 5
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 12, width: 35, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 7, width: size, height: size))
    
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    
}

