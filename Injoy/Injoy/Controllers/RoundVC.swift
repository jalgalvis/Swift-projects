//
//  ViewController.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 8/10/17.
//  Copyright © 2017 Juan Alejandro Galvis. All rights reserved.
//

import UIKit
import SVProgressHUD

class RoundVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var tableViewRound: UITableView!
    @IBOutlet weak var labelSubtotalOrder: UILabel!
    @IBOutlet weak var buttonConfirmBill: UIButton!
    
    var listOfRoundableProducts = [Order]()
    let sessionInfo = Session.getsessionRealm()

    
    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonConfirmBill.backgroundColor = sessionInfo.placeColor
        view.tintColor = sessionInfo.placeColor
        labelSubtotalOrder.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        
        listOfRoundableProducts = receiveDataFromServerOrderClass(sessionID: sessionInfo.sessionID, action: .round)
        let value = String(format: "%d", locale: Locale.current, listOfRoundableProducts.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
        labelSubtotalOrder.text = "Subtotal: COP$ \(value)"
    }
    
    //MARK: Methods
    
    @IBAction func stepperQty(_ sender: UIStepper) {
        
        listOfRoundableProducts[sender.tag].productQty = Int(sender.value)
        tableViewRound.reloadData()
        let value = String(format: "%d", locale: Locale.current, listOfRoundableProducts.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
        labelSubtotalOrder.text = "Subtotal: COP$ \(value)"
    }
    
    @IBAction func buttonActionConfirmBll(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Desea confirmar el pedido?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        alertController.addAction(cancelAction)
        let destroyAction = UIAlertAction(title: "Confirmar", style: .destructive) { action in
            
            // Set OrderID = Date-Time
            let CurrentTime = Date()
            let OrderIDString = self.sessionInfo.codeDate(DateToSave: CurrentTime) //func to Coding format string without AM - PM
            
            self.listOfRoundableProducts.forEach {
                $0.sessionID = self.sessionInfo.sessionID
                $0.orderID = OrderIDString
                $0.payerName = 0
                $0.billTip = 10
            }
            sendDataToServer(action: .orders, dataToSend: self.listOfRoundableProducts)
            sendDataToServer(action: .clearRound, sessionID: self.sessionInfo.sessionID)
            self.sessionInfo.status = 3
            Session.updateRealm(newSession: self.sessionInfo)
            sendDataToServer(action: .sessionStatus, sessionID: self.sessionInfo.sessionID, Option: 3)
            
            self.listOfRoundableProducts.forEach { $0.orderID = "Round" }
            sendDataToServer(action: .orders, dataToSend: self.listOfRoundableProducts)
            
            // Alert Confirm Order
            SVProgressHUD.showSuccess(withStatus: "Orden confirmada")
            SVProgressHUD.dismiss(withDelay: 2)
            
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true)
    }
}

//MARK: - UITableViewDataSource Methods

extension RoundVC: UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRoundableProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell") as! ReusableCell
        
        let product = listOfRoundableProducts[indexPath.row]
        DispatchQueue.main.async {
            cell.productPhoto.image = UIImage()
            cell.productPhoto.image = productList[product.productID]?.photo
        }
        cell.productName.text = product.productName
        cell.productDefaultOption.text = product.productOptionPrice.first?.key
        cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * (product.productOptionPrice.first?.value)!))"
        cell.productQtyStepper.value = Double(product.productQty)
        cell.productQtyStepper.tag = indexPath.row
        cell.productQty.text = String(Int(cell.productQtyStepper.value))
        
        
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            listOfRoundableProducts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let value = String(format: "%d", locale: Locale.current, listOfRoundableProducts.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
            labelSubtotalOrder.text = "Subtotal: COP$ \(value)"
            
            if listOfRoundableProducts.count == 0 {
                
                SVProgressHUD.showError(withStatus: "Orden Vacia")
                SVProgressHUD.dismiss(withDelay: 2)
                self.navigationController?.popViewController(animated: true)
                
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
