//
//  Register.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 29/4/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class RegisterVC: UIViewController {
    
    
    
    //MARK: Properties
    
    @IBOutlet weak var textFieldUserEmail: UITextField!
    @IBOutlet weak var textFieldUserPassword: UITextField!
    @IBOutlet weak var viewTextFields: UIView!
    @IBOutlet weak var registerUser: UIButton!
    
    var offsetY:CGFloat = 0
    var sessionInfo = Session()

    
    //MARK: Methods
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        
        textFieldUserEmail.delegate = self
        textFieldUserPassword.delegate = self
        
    }
    
    
    //MARK: Actions
    
    @IBAction func buttonRegisterUser(_ sender: UIButton) {
        guard let userEmail = textFieldUserEmail.text, let userPassword = textFieldUserPassword.text else {
            return
        }
        SignUp(userEmail: userEmail, password: userPassword) { (authenticationSuccesful) in
            if authenticationSuccesful {
                let sessionInfo = Session()
                sessionInfo.userEmail = self.textFieldUserEmail.text!
                sessionInfo.userPassword = self.textFieldUserPassword.text!
                Session.createRealm(newSession: sessionInfo)
                self.performSegue(withIdentifier: "segueRegister2QR", sender: self)
            }
        }
    }
    
    func SignUp (userEmail : String, password : String, completion: @escaping (Bool) -> Void){
        var errmessage = ""
        Auth.auth().createUser(withEmail: textFieldUserEmail.text!, password: textFieldUserPassword.text!) {
            (user, error) in
            if let error = error {
                switch AuthErrorCode(rawValue: error._code) {
                    
                case .weakPassword?:
                    errmessage = "Contraseña muy débil"
                case .emailAlreadyInUse?:
                    errmessage = "Correo ya esta en uso"
                case .invalidEmail?:
                    errmessage = "Correo invalido"
                case .missingEmail?:
                    errmessage = "Falta correo electrónico"
                case .wrongPassword?:
                    errmessage = "Contraseña errada"
                default:
                    errmessage = "Inconvenientes en el registro"
                }
                SVProgressHUD.showError (withStatus: errmessage)
                SVProgressHUD.dismiss(withDelay: 1) {
                    print("SignUp failed")
                    completion(false)
                }
                
            } else {
                SVProgressHUD.showSuccess (withStatus: "Registro Exitoso")
                SVProgressHUD.dismiss(withDelay: 1) {
                    print("LogIn succesful")
                    completion(true)
                }

                
            }
        }

    }
    
}

//MARK: - UITextFieldDelegate

extension RegisterVC: UITextFieldDelegate {
    @objc func keyboardFrameChangeNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
            let animationCurveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue)
            let animationCurve = UIView.AnimationOptions(rawValue: UInt(animationCurveRawValue))
            if let _ = endFrame, endFrame!.intersects(self.viewTextFields.frame) {
                self.offsetY = self.viewTextFields.frame.maxY - endFrame!.minY
                UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                    self.viewTextFields.frame.origin.y = self.viewTextFields.frame.origin.y - self.offsetY
                }, completion: nil)
            } else {
                if self.offsetY != 0 {
                    UIView.animate(withDuration: animationDuration, delay: TimeInterval(0), options: animationCurve, animations: {
                        self.viewTextFields.frame.origin.y = self.viewTextFields.frame.origin.y + self.offsetY
                        self.offsetY = 0
                    }, completion: nil)
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        if textField == textFieldUserEmail{
            textFieldUserEmail.resignFirstResponder()
            textFieldUserPassword.becomeFirstResponder()
            if !(textFieldUserEmail.text?.isEmpty)! && !(textFieldUserPassword.text?.isEmpty)!{
                registerUser.isEnabled = true
            }
        }
        if textField == textFieldUserPassword{
            textFieldUserPassword.resignFirstResponder()
            if !(textFieldUserEmail.text?.isEmpty)! && !(textFieldUserPassword.text?.isEmpty)!{
                registerUser.isEnabled = true
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textFieldUserEmail{
            textFieldUserEmail.text = textField.text
        }
        if textField == textFieldUserPassword{
            textFieldUserPassword.text = textField.text
        }
        
    }
    
}
