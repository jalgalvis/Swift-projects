import UIKit
import AVFoundation
import SVProgressHUD
import RealmSwift
import Firebase

class QRReaderVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var imageSquareQRReaderTarget: UIImageView!
    @IBOutlet weak var QRInstructions: UIView!
    @IBOutlet weak var testButtonShow: UIView!
    @IBOutlet weak var signOutButton: UIView!
    @IBOutlet weak var viewQRTarget: UIImageView!
    
    let session = AVCaptureSession()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var sessionInfo = Session.getsessionRealm()
    var placeColorLocal = UIColor()
    var backgroundImage = UIImage()
    
    let horizontalBar: UIView = {
        let hb = UIView()
        hb.backgroundColor = UIColor.green
        return hb
    }()
    
    //Creating session
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        cameraSession()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func startReadingQR () {
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        horizontalBar.frame = CGRect(x: viewQRTarget.frame.origin.x, y: viewQRTarget.frame.origin.y, width: viewQRTarget.frame.width, height: 5)
        view.addSubview(horizontalBar)
        view.addSubview(viewQRTarget)
        
        
        UIView.animate(withDuration: 5, delay: 0, options: [.autoreverse, .repeat], animations: {
            let origin = self.horizontalBar.frame.origin.y
            let movement = self.viewQRTarget.frame.height - self.horizontalBar.frame.height
            self.horizontalBar.frame.origin.y = origin + movement
        })
    }
    
    func stopReadingQR () {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
            horizontalBar.removeFromSuperview()
            view.layer.removeAllAnimations()
        }
    }
    
    func cameraSession () {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            sessionFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            sessionFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        startReadingQR()
        let scanRect = viewQRTarget.frame
        let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
        
        metadataOutput.rectOfInterest = rectOfInterest
    }
    
    func setUI () {
        view.backgroundColor = UIColor.black
        self.view.bringSubviewToFront(imageSquareQRReaderTarget)
        self.view.bringSubviewToFront(QRInstructions)
        self.view.bringSubviewToFront(testButtonShow)
        self.view.bringSubviewToFront(signOutButton)
        
    }
    
    func sessionFailed() {
        let ac = customUIAlertView(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func found(QRCode: String) {
        
        let QRTextArray = QRCode.components(separatedBy: ",")
        if QRTextArray.count == 3 && QRTextArray[0] == "Injoy"
        {
            if let placeIDInt = Int(QRTextArray[1]) {
                sessionInfo.placeID = placeIDInt
            } else {
                print("Error in place ID")
            }
            if let tableIDInt = Int(QRTextArray[2]) {
                sessionInfo.tableNumber = tableIDInt
            } else {
                print("Error in table number")
            }
            let result = receiveDataFromServerPlaceName(placeID: sessionInfo.placeID)
            if result.succesful {
                sessionInfo.placeName = result.data
            } else {
                SVProgressHUD.showError(withStatus: "Lo sentimos, error en la conexión, por favor intente en unos momentos")
                SVProgressHUD.dismiss(withDelay: 2) {
                    self.startReadingQR()
                    return
                }
            }
            activateSession()
            
        } else {
            
            SVProgressHUD.showError(withStatus: "Código no reconocido, vuelve a intentar")
            SVProgressHUD.dismiss(withDelay: 3) {
                self.startReadingQR()
            }
        }
    }
    
    func activateSession() {
        stopReadingQR()
        SVProgressHUD.show(withStatus: "Estas ingresando a \(sessionInfo.placeName) en la mesa # \(sessionInfo.tableNumber)")
        
        let group = DispatchGroup()
        let CurrentTime = Date()
        
        sessionInfo.sessionID = sessionInfo.codeDate(DateToSave: CurrentTime) //func to Coding format string without AM - PM
        group.enter()
        let currentSessionToSend = SessionToSend(SessionID: sessionInfo.sessionID, PlaceID: sessionInfo.placeID, TableID: sessionInfo.tableNumber, userEmail: sessionInfo.userEmail, userPassword: sessionInfo.userPassword)
        sendDataToServer1(action: .session, dataToSend: currentSessionToSend){
            receiveDataFromServerGeneralInfo (placeID: self.sessionInfo.placeID) { (image, color) in
                let placeInfo = (backgroundImage: image, placeColor: color)
                self.sessionInfo.backgroundImageURL = placeInfo.backgroundImage
                var placeColorString = placeInfo.placeColor
                placeColorString.remove(at: placeColorString.startIndex)
                self.sessionInfo.placeColorString = placeColorString
                if let image = UIImage(url: URL(string: self.sessionInfo.backgroundImageURL)) {
                    if let imageString = image.jpegData(compressionQuality: 0.75){
                        self.sessionInfo.backgroundImageData = imageString.base64EncodedString()
                    }
                }
                Session.createRealm(newSession: self.sessionInfo)
                
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "segueQR2Checked", sender: self)
        }
    }
    
    //MARK: Actions
    
    @IBAction func signOutButton(_ sender: UIButton) {
        
        
        
        let alertController = UIAlertController(title: nil, message: "Desea ingresar con otro usuario?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Confirmar", style: .destructive) { action in
            SVProgressHUD.showSuccess(withStatus: "Log out exitoso")
            
            do{
                try Auth.auth().signOut()
                print("log out sucessful")
            } catch { print("error signing out")}
            
            let realm = try! Realm()
            do {
                try realm.write {
                    realm.deleteAll()
                }
            } catch {
                print("error logingOut: \(error)")
            }
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoggedVC") as! LoggedVC
            let firstViewController = UINavigationController.init(rootViewController: viewController)
            
            let appDelegate = UIApplication.shared.delegate
            SVProgressHUD.dismiss(withDelay: 2)
            appDelegate?.window??.rootViewController = firstViewController
            
            
            
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
        
    }
    @IBAction func TestButton(_ sender: UIButton) {
        found(QRCode: "Injoy,1,77")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "segueQR2Checked" {
            if let CTVC = segue.destination as? CustomTabVC {
                if let NC = CTVC.viewControllers?.first as? NavigationController {
                    if let VC = NC.viewControllers.first as? CheckedVC {
                        VC.backgroundImage = self.backgroundImage
                    }
                }
            }
        }
    }
}




//MARK: - QRReader extension VCaptureMetadataOutputObjectsDelegate methods

extension QRReaderVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopReadingQR()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(QRCode: stringValue)
        }
    }
}


