import UIKit
import os.log


class OrderTableViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBAction func BackButtonMenu(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ConfirOrder(_ sender: UIButton) {
        
        // Ask Confir Order
        
        let alertController = UIAlertController(title: nil, message: "Desea confirmar su orden con sus elecciones?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Confirmar", style: .destructive) { action in
            
                    // Alert Confirm Order
                    let alertController = UIAlertController(title: "Orden Confirmada", message: "Será servida en 15 mins", preferredStyle: .alert)
            
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                        GlobalVariables.ExistOrder = false
                        GlobalVariables.Orders.removeAll()
                        GlobalVariables.Invoice.append(contentsOf: GlobalVariables.Orders)
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(OKAction)
            
            
                    self.present(alertController, animated: true) {
                        // ...
                    }
        }
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the sample data.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Cells height adjustment
        return 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalVariables.Orders.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "OrderTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate Product for the data source layout.
        let product = GlobalVariables.Orders[indexPath.row]
        
        cell.ProductName.text = product.ProductName
        cell.ProductPhoto.image = product.ProductPhoto
        cell.ProductDefaultOption.text = product.ProductDefaultOption
        cell.ProductPrice.text = String(product.ProductPrice)
        cell.ProductQty.text = String(product.ProductQty)
        
        return cell
    }
    

}




