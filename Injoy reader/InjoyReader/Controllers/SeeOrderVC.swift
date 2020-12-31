import UIKit



class SeeOrderVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var labelSubtotalOrder: UILabel!
    @IBOutlet weak var tableViewOrderToSee: UITableView!
    @IBOutlet weak var imageQRCode: UIImageView!
    var orderArray = [Order]()
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dump(orderArray)
        

        }
        
}

//MARK: - UITableViewDataSource Methods


extension SeeOrderVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewOrderCell") as! ReusableCell
        
        let product = orderArray[indexPath.row]
        
        cell.productName.text = product.productName
        cell.productPhoto.image = product.productImage
        cell.productDefaultOption.text = product.productOptionPrice.first?.key
        cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * (product.productOptionPrice.first?.value)!))"
        cell.productQty.text = String(product.productQty)
        
        return cell
    }
    
    
    
}
