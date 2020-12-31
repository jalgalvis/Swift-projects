import UIKit
import SVProgressHUD

class OrderVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var subtotalOrder: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var order = [Order]()
    let sessionInfo = Session.getsessionRealm()

    //MARK: Methods
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        let value = String(format: "%d", locale: Locale.current, order.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
        subtotalOrder.text = "Subtotal: COP$ \(value)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = sessionInfo.placeColor
        subtotalOrder.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        confirmButton.backgroundColor = sessionInfo.placeColor
    }
    
    func confirmOrder () {
        
        let currentTime = Date()
        let orderIDString = sessionInfo.codeDate(DateToSave: currentTime) //func to Coding format string without AM - PM
        // Send Order
        
        self.order.forEach {
            $0.sessionID = sessionInfo.sessionID
            $0.orderID = orderIDString
            $0.payerName = 0
            $0.billTip = 10
        }
        sendDataToServer(action: .orders, dataToSend: self.order)
        
        
        sessionInfo.billExistFlag = true
        if self.order.filter({$0.productRoundableFlag == true}).count > 0 {
            sendDataToServer(action: .clearRound, sessionID: sessionInfo.sessionID)
            
            let roundOrder = self.order.filter { $0.productRoundableFlag == true }
            roundOrder.forEach {
                $0.orderID = "Round"
                $0.payerName = 0
                $0.billTip = 10
            }
            sessionInfo.roundExistFlag = true
            sendDataToServer(action: .orders, dataToSend: roundOrder)
            
            
        }
        sessionInfo.status = 3
        Session.updateRealm(newSession: sessionInfo)
        sendDataToServer(action: .sessionStatus, sessionID: sessionInfo.sessionID, Option: 3)
        self.order = [Order]()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier  == "segueOrder2EditProduct" {
            
            
            guard let productDetailViewController = segue.destination as? EditProductVC else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedProductCell = sender as? ReusableCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedProductCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedProduct = indexPath.row
            productDetailViewController.selectedProduct = selectedProduct
            productDetailViewController.orderLineToModify = order[selectedProduct]
//            productDetailViewController.sessionInfo = sessionInfo
            
        }
    }
    
    //MARK: Actions
    
    @IBAction func unwindToOrderView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditProductVC,
            let orderLineToModify = sourceViewController.orderLineToModify,
            let selectedProduct = sourceViewController.selectedProduct {
            
            order[selectedProduct] = orderLineToModify
        }
        
        
    }
    
    @IBAction func stepperQty(_ sender: UIStepper) {
        order[sender.tag].productQty = Int(sender.value)
        tableView.reloadData()
        let value = String(format: "%d", locale: Locale.current, order.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
        subtotalOrder.text = "Subtotal: COP$ \(value)"
    }
    
    @IBAction func buttonConfirmOrder(_ sender: UIButton) {
        
        
        // Ask Confirm Order
        let alertController = UIAlertController(title: nil, message: "Desea confirmar su orden con sus elecciones?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Confirmar", style: .destructive) { action in
            SVProgressHUD.showSuccess(withStatus: "Orden Confirmada")
            self.confirmOrder()
                SVProgressHUD.dismiss(withDelay: 2)
                self.performSegue(withIdentifier: "unwindSegueOrder2Meal", sender: self)
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
            
        }
    }
    
}
//MARK: - UITableViewDataSource methods

extension OrderVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! ReusableCell
        let product = order[indexPath.row]

        DispatchQueue.main.async {
            cell.productPhoto.image = UIImage()
            cell.productPhoto.image = productList[product.productID]?.photo
        }
        cell.productName.text = product.productName
        if let productDefaultOptionItem = product.productOptionPrice.first {
            cell.productDefaultOption.text = productDefaultOptionItem.key
            cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * productDefaultOptionItem.value))"
        }
        
        cell.productQtyStepper.value = Double(product.productQty)
        cell.productQtyStepper.tag = indexPath.row
        cell.productQty.text = String(product.productQty)
        
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            order.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let value = String(format: "%d", locale: Locale.current, order.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
            subtotalOrder.text = "Subtotal: COP$ \(value)"
            
            if order.count == 0 {
                
                SVProgressHUD.showError(withStatus: "Orden Vacia")
                SVProgressHUD.dismiss(withDelay: 2)
                self.navigationController?.popViewController(animated: true)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

