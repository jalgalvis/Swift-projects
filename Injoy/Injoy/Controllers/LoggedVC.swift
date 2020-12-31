import UIKit
import SVProgressHUD
import Firebase
import RealmSwift


class LoggedVC: UIViewController {
    
    
    //MARK: Properties
    @IBOutlet weak var textFieldUserEmail: UITextField!
    @IBOutlet weak var textFieldUserPassword: UITextField!
    @IBOutlet weak var viewTextFields: UIView!
    
    var offsetY:CGFloat = 0
    
    //MARK: Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        textFieldUserEmail.delegate = self
        textFieldUserPassword.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    
    //MARK: Actions
    
    func checkIn () {
        guard let userEmail = textFieldUserEmail.text, textFieldUserEmail.text != "" else {return}
        guard let userPassword = textFieldUserPassword.text, textFieldUserPassword.text != "" else {return}
        logIn(userEmail: userEmail, password: userPassword) { (authenticationSuccesful) in
            if authenticationSuccesful {
                let sessionInfo = Session()
                sessionInfo.userEmail = userEmail
                sessionInfo.userPassword = userPassword
                Session.createRealm(newSession: sessionInfo)
                self.performSegue(withIdentifier: "segueLogged2QR", sender: self)
            }
        }
    }
    
    @IBAction func buttonRegister(_ sender: UIButton) {
        performSegue(withIdentifier: "segueLogged2Register", sender: self)
    }
    
    func logIn (userEmail : String, password : String, completion: @escaping (Bool) -> Void){
        var errMessage = ""
        
        Auth.auth().signIn(withEmail: userEmail, password: password) {
            (user, error) in
            if let error = error {
                switch AuthErrorCode(rawValue: error._code) {
                    
                case .invalidEmail?:
                    errMessage = "Correo invalido"
                case .wrongPassword?:
                    errMessage = "Contraseña errada"
                default:
                    errMessage = "Inconvenientes en el registro"
                }
                SVProgressHUD.showError (withStatus: errMessage)
                SVProgressHUD.dismiss(withDelay: 1) {
                    print("LogIn failed")
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

//MARK: UITextFieldDelegate


extension LoggedVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        if textField == textFieldUserEmail{
            
            textFieldUserEmail.resignFirstResponder()
            textFieldUserPassword.becomeFirstResponder()
            
        }
        if textField == textFieldUserPassword{
            textFieldUserPassword.resignFirstResponder()
            checkIn()
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


