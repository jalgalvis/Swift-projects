import UIKit
import SVProgressHUD
import Firebase
import RealmSwift

class CheckedVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var viewRoundButtonView: UIView!
    @IBOutlet weak var buttonRequestBill: UIButton!
    @IBOutlet weak var labelTableNumber: UILabel!
    @IBOutlet weak var viewBackgroundImage: UIImageView!
    @IBOutlet weak var viewBackgroundInfo: UIView!
    @IBOutlet weak var labelDateInfo: UILabel!
    @IBOutlet weak var tableViewBillSummary: UITableView!
    @IBOutlet weak var buttonExit: UIButton!
    @IBOutlet weak var buttonSubtotalText: UIButton!
    @IBOutlet weak var flippingButton: UIButton!
    @IBOutlet var viewBill: UIVisualEffectView!
    @IBOutlet weak var mainView: UIView!
    
    var summaryOrdersTotalPrice = [OrderSummary]()
    var order = [Order]()
    var selectedOrder = ""
    var sessionInfo = Session.getsessionRealm()
    var backgroundImage: UIImage?
    
    
    //MARK: Methods
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()

        if let imageData = Data(base64Encoded: sessionInfo.backgroundImageData, options: .ignoreUnknownCharacters) {
            if let image = UIImage(data: imageData) {
                viewBackgroundImage.image = image
            }
        }
            


            
        receiveDataFromServerProducts (placeID: sessionInfo.placeID) { (list) in
            productList = Dictionary(grouping: list.sorted(by: {$0.productID < $1.productID}), by: { $0.productID}).mapValues { $0.first! }
        }
        



        
        //setup bill Summary View
        
        guard let tabBarController = self.tabBarController else { return }
        viewBill.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - flippingButton.frame.height-tabBarController.tabBar.frame.height, width: viewBill.frame.width, height: viewBill.frame.height)
        mainView.addSubview(viewBill)
        
        
        
        self.title = sessionInfo.placeName
        
        //change the name in the Navigation Bar

        view.tintColor = sessionInfo.placeColor
        // Print TableNumber & Current Time
        labelTableNumber.text = "Mesa \(sessionInfo.tableNumber)"
        labelDateInfo.text = "Ingreso: \(sessionInfo.deCodeDate(ExpectedFormat: "MMM dd  h:mm a", CodedDate: sessionInfo.sessionID))"
        
        // Change Button Colors
        viewBackgroundInfo.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        viewRoundButtonView.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        buttonRequestBill.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        buttonExit.setTitleColor(sessionInfo.placeColor, for: .normal)
    }
    
    
    @IBAction func buttonBillDisplay(_ sender: UIButton) {
        toogleDisplayBill()
    }
    func toogleDisplayBill() {
        if viewBill.transform == .identity {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                self.viewBill.transform = CGAffineTransform(translationX: 0, y: -self.viewBill.frame.height + self.flippingButton.frame.height + 50 )
                self.flippingButton.transform = CGAffineTransform(rotationAngle: 3.14)
                
            })
            
        } else {
            hideDisplayBill()
        }
    }
    
    func hideDisplayBill() {
        if viewBill.transform != .identity {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                self.viewBill.transform = .identity
                self.flippingButton.transform = .identity
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        sessionInfo = Session.getsessionRealm()
        buttonExit.isHidden = sessionInfo.billExistFlag
        viewRoundButtonView.isHidden = !sessionInfo.roundExistFlag
        viewBill.isHidden = !sessionInfo.billExistFlag
        if sessionInfo.billExistFlag {
            displayOrdersSummary()
        } else {
            hideDisplayBill()
        }
    }
    
    func displayOrdersSummary (){
        let BillReference = receiveDataFromServerOrderClass(sessionID: sessionInfo.sessionID, action: .bill)
        let bill = BillReference.filter { $0.payerName == 0}
        summaryOrdersTotalPrice = [OrderSummary]()
        let SummaryOrders = bill.map { $0.orderID }
        let SummaryOrdersUnique = Set(SummaryOrders)
        for Order in SummaryOrdersUnique {
            let TotalPrice = bill.filter {$0.orderID == Order}
            let OrderSummaryItems = OrderSummary(orderID: Order, orderTotalPrice: TotalPrice.reduce(0) {
                $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!)
            })
            summaryOrdersTotalPrice.append(OrderSummaryItems)
        }
        tableViewBillSummary.reloadData()
        let value = String(format: "%d", locale: Locale.current, summaryOrdersTotalPrice.reduce(0) { $0 + $1.orderTotalPrice })
        buttonSubtotalText.setTitle("Subtotal: $ \(value)", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier  == "segueChecked2SeeOrder" {
            
            if let DestinationVC = segue.destination as? SeeOrderVC  {
                if let selectedOrderCell = sender as? ReusableCell, let indexPath = tableViewBillSummary.indexPath(for: selectedOrderCell) {
                    let tableOrder = summaryOrdersTotalPrice[indexPath.row]
                    selectedOrder = tableOrder.orderID
                    DestinationVC.selectedOrder = selectedOrder
                    //                    DestinationVC.sessionInfo = sessionInfo
                }
            }
        }
    }
    
    
    
    @IBAction func unwindToChecked(sender: UIStoryboardSegue) {
        
        
    }
    
    
    
    //MARK: Actions
    
    @IBAction func buttonExit(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Confirmar salida?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Confirmar", style: .destructive) { action in
            SVProgressHUD.showSuccess(withStatus: "Gracias por venir a \(self.sessionInfo.placeName), te esperamos pronto")

            self.sessionInfo.status = 2
            Session.updateRealm(newSession: self.sessionInfo)
            sendDataToServer(action: .sessionStatus, sessionID: self.sessionInfo.sessionID, Option: 2)
                SVProgressHUD.dismiss()
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let firstViewController = storyboard.instantiateViewController(withIdentifier: "QRReaderNC") as!
            UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = firstViewController
            self.view.window!.rootViewController?.dismiss(animated: true)
 

            
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
}

//MARK: - extension Checked UITableViewDataSource methods

extension CheckedVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaryOrdersTotalPrice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell") as! ReusableCell
        
        let product = summaryOrdersTotalPrice[indexPath.row]
        cell.productName.text = sessionInfo.deCodeDate(ExpectedFormat: "MMM dd   hh:mm a", CodedDate: product.orderID)
        cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.orderTotalPrice))"
        
        return cell
    }
    
}
