import UIKit
import SVProgressHUD

class BillVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var tableViewOrder: UITableView!
    @IBOutlet weak var buttonDivideBill: UIButton!
    @IBOutlet weak var labelTotalBill: UILabel!
    @IBOutlet weak var labelSubTotalBill: UILabel!
    @IBOutlet weak var labelTipValue: UILabel!
    @IBOutlet weak var labelTip: UILabel!
    @IBOutlet weak var sliderTip: UISlider!
    @IBOutlet weak var buttonAskBill: UIButton!
    
    var bill = [Order]()
    var tip: Int = 10
    let sessionInfo = Session.getsessionRealm()

    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let BillReference = receiveDataFromServerOrderClass(sessionID: sessionInfo.sessionID, action: .bill)
        bill = BillReference.filter { $0.payerName == 0 }
        buttonDivideBill.backgroundColor = sessionInfo.placeColor
        buttonAskBill.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.1)
        view.tintColor = sessionInfo.placeColor
        updateSubtotals()
        
        
    }
    
    func updateSubtotals(){
        
        let SubTotalBillInt = bill.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) }
        labelSubTotalBill.text = "$ \(String(format: "%d", locale: Locale.current, SubTotalBillInt))"
        let TipValueInt = Int(Double(SubTotalBillInt)/(1 + (8 / 100)) * Double(tip) / 100)
        labelTipValue.text = "$ \(String(format: "%d", locale: Locale.current, TipValueInt))"
        labelTip.text = "Propina \(tip)%"
        let TotalBillInt = SubTotalBillInt + TipValueInt
        labelTotalBill.text = "$ \(String(format: "%d", locale: Locale.current, TotalBillInt))"
        sliderTip.value = Float(tip)
    }
    

    //MARK: Actions
    
    @IBAction func buttonAskBill(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Desea pedir el total de su cuenta?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        let destroyAction = UIAlertAction(title: "Aceptar", style: .destructive) { action in
            SVProgressHUD.showSuccess(withStatus: "Cuenta procesada, será llevada en Breve")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.sessionInfo.roundExistFlag = false
                self.sessionInfo.billExistFlag = false
                Session.updateRealm(newSession: self.sessionInfo)
                self.sessionInfo.status = 1
                Session.updateRealm(newSession: self.sessionInfo)
                sendDataToServer(action: .sessionStatus, sessionID: self.sessionInfo.sessionID, Option: 1)
                sendDataToServer(action: .clearPendigBill, sessionID: self.sessionInfo.sessionID)
                self.bill.filter { $0.payerName == 0 }.forEach {
                    $0.billTip = self.tip
                    $0.payerName = 1
                }
                sendDataToServer(action: .orders, dataToSend: self.bill)
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "unwindSegueBill2Checked", sender: self)
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
    
    @IBAction func tipSlider(_ sender: UISlider) {
        tip = Int(sender.value)
        updateSubtotals()
    }

}

//MARK: - UITableViewDataSource Methods

extension BillVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bill.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell") as! ReusableCell
        let product = bill[indexPath.row]
        
        cell.productName.text = product.productName
        DispatchQueue.main.async {
            cell.productPhoto.image = UIImage()
            cell.productPhoto.image = productList[product.productID]?.photo
        }
        cell.productDefaultOption.text = product.productOptionPrice.first?.key
        cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * (product.productOptionPrice.first?.value)!))"
        cell.productQty.text = String(product.productQty)
        
        return cell
    }
    
}
