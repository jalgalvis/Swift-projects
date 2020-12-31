import UIKit


class SeeOrderVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var labelSubtotalOrder: UILabel!
    @IBOutlet weak var tableViewOrderToSee: UITableView!
    @IBOutlet weak var imageQRCode: UIImageView!
    var listOfUnpaidProductsInOrder = [Order]()
    var selectedOrder : String?
    let sessionInfo = Session.getsessionRealm()

    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelSubtotalOrder.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        view.tintColor = sessionInfo.placeColor


        let ListOfProductsInOrder = receiveDataFromServerOrderClass(sessionID: sessionInfo.sessionID, orderID: selectedOrder!, action: .order)
        
        listOfUnpaidProductsInOrder = ListOfProductsInOrder.filter { $0.payerName == 0 }
        let value = String(format: "%d", locale: Locale.current, listOfUnpaidProductsInOrder.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) })
        
        labelSubtotalOrder.text = "Subtotal: COP$ \(value)"
        
        let orderString = encodeOrderToString(from: ListOfProductsInOrder)
        imageQRCode.image = generateQRCode(from: orderString)
        
    }
    
    func encodeOrderToString(from orderList: [Order]) -> String{
        var arrayFromOrderList = [Int:Int]()
        orderList.forEach { (orderLine) in
            arrayFromOrderList[orderLine.productID] = orderLine.productQty
            
        }
        
        
        do {
            let encodedData = try JSONEncoder().encode(arrayFromOrderList)
            return String(data: encodedData, encoding: String.Encoding.utf8)!
        } catch {
            return ""
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
    
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
    
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
    
        return nil
    }
    


}

//MARK: - UITableViewDataSource Methods


extension SeeOrderVC: UITableViewDataSource {
    
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfUnpaidProductsInOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewOrderCell") as! ReusableCell
        
        let product = listOfUnpaidProductsInOrder[indexPath.row]

        DispatchQueue.main.async {
            cell.productPhoto.image = UIImage()
            cell.productPhoto.image = productList[product.productID]?.photo
        }
        cell.productName.text = product.productName
        cell.productDefaultOption.text = product.productOptionPrice.first?.key
        cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * (product.productOptionPrice.first?.value)!))"
        cell.productQty.text = String(product.productQty)
        
        return cell
    }
    
    
    
}
