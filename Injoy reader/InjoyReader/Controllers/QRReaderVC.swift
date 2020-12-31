import UIKit
import AVFoundation
import SVProgressHUD


class QRReaderVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var imageSquareQRReaderTarget: UIImageView!
    @IBOutlet weak var QRInstructions: UILabel!
    @IBOutlet weak var TestButtonShow: UIButton!
    @IBOutlet weak var viewQRTarget: UIImageView!
    @IBOutlet weak var animatedLine: UIView!
    
    let session = AVCaptureSession()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var order = [Order]()
    
    
    //Creating session
    
    //MARK: Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraSession()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
            startReadingQR()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destinationVC = segue.destination as? SeeOrderVC {
                destinationVC.orderArray = order

        }
        
    }
    
    func startReadingQR () {
        

        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
            UIView.animate(withDuration: 4, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
                let origin = self.animatedLine.frame.origin.y + 4
                let movement = self.viewQRTarget.frame.height - 8
                self.animatedLine.frame.origin.y = origin + movement
            }, completion: nil)
        }
    }
    
    func stopReadingQR () {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
            animatedLine.layer.removeAllAnimations()
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
        self.view.bringSubviewToFront(animatedLine)
        self.view.bringSubviewToFront(imageSquareQRReaderTarget)
        self.view.bringSubviewToFront(QRInstructions)
    }
    
    func sessionFailed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    

    
    
    //MARK: Actions
    
}

//MARK: - QRReader extension VCaptureMetadataOutputObjectsDelegate methods

extension QRReaderVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopReadingQR()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.showSuccess(withStatus: "Orden Leida")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            do {
                let encodedData = stringValue.data(using: String.Encoding.utf8)!
                let orderArray = try JSONDecoder().decode([Int:Int].self, from: encodedData)

                
                
                let productList = receiveDataFromServerProducts(placeID: 1)
                
                for orderLineinArray in orderArray {
                    if let i = productList.index(where: { $0.productID == orderLineinArray.key }) {
                        let orderLine = Order(productID: orderLineinArray.key, productName: productList[i].productName, productOptionPrice: productList[i].productOptionPrice, productQty: orderLineinArray.value, productImage: productList[i].photo)
                        self.order.append(orderLine)
                    }
                }
            } catch {
                
            }
            
            
            
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "segueQR2Order", sender: self)
            }
        }
    }
    

}




