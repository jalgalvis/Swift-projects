import UIKit
import os.log
import SVProgressHUD

class ProductVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var buttonOrderProduct: UIButton!
    @IBOutlet weak var pickerViewProductOptions: UIPickerView!
    @IBOutlet weak var labelQty: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var textViewProductDescription: UITextView!
    @IBOutlet weak var switchProductRoundableOption: UISwitch!
    @IBOutlet weak var viewRoundOptionBackground: UIView!
    @IBOutlet weak var qtyStepper: UIStepper!
    
    var listOfProductOptions: [String] = []
    var listOfProductOptionsForPickerView: [String] = []
    var listOfOptionsAndPrices: [String:Int] = [:]
    var pickerViewCurrentValue: String = ""
    var productKind: String = ""
    var productID: Int = 0
    var productVAT: Int = 0
    var price: Int = 0
    var product: Product?
    var order = [Order]()
    let sessionInfo = Session.getsessionRealm()

    //MARK: Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        switchProductRoundableOption.onTintColor = sessionInfo.placeColor
        viewRoundOptionBackground.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
        view.tintColor = sessionInfo.placeColor
        buttonOrderProduct.backgroundColor = sessionInfo.placeColor
        
        if let product = product {
            self.title = product.productName
            imageProduct.image = product.photo
            textViewProductDescription.text = product.productDescription
            listOfOptionsAndPrices = product.productOptionPrice
            // Sort dictionary of Options from cheapest to Most Expensive
            let ProductOptionPriceSorted = listOfOptionsAndPrices.sorted(by: { $0.value < $1.value })
            // Array for PickerView
            listOfProductOptionsForPickerView = ProductOptionPriceSorted.map { $0.key }
            listOfProductOptions = listOfProductOptionsForPickerView
            for (index,element) in listOfProductOptionsForPickerView.enumerated() {
                listOfProductOptionsForPickerView[index] += "   $ \(String(format: "%d", locale: Locale.current, product.productOptionPrice[element]!))"
            }
            
            pickerViewCurrentValue = listOfProductOptions[0]
            price = product.productOptionPrice[pickerViewCurrentValue]!
            productKind = product.productKind
            switchProductRoundableOption.isOn = product.roundableFlag
            productID = product.productID
            productVAT = product.productVAT
            if let indexInOrder = self.order.index(where: { $0.productID == productID && $0.productOptionPrice.first?.key == pickerViewCurrentValue}) {
                labelQty.text = String(self.order[indexInOrder].productQty)
                qtyStepper.value = Double(self.order[indexInOrder].productQty)
            }
        }
    }
    
    //MARK: Actions
    
    
    @IBAction func buttonOrderProduct(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Desea agregar \(self.title ?? "") a su orden?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            return
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Agregar", style: .destructive) { action in
            SVProgressHUD.showSuccess(withStatus: "Producto Agregado")
            if let indexInOrder = self.order.index(where: { $0.productID == self.productID && $0.productOptionPrice.first?.key == self.pickerViewCurrentValue}) {
                self.order[indexInOrder].productQty = Int(self.labelQty.text!)!
            } else {
                
                let newOrderLine = Order(sessionID: self.sessionInfo.sessionID,
                                         orderID: "",
                                         productID: self.productID,
                                         productName: self.title!,
                                         productOptionPrice: [self.pickerViewCurrentValue : self.price],
                                         productDefaultOption: self.pickerViewCurrentValue,
                                         productKind: self.productKind,
                                         productQty: Int(self.labelQty.text!)!,
                                         productVAT: self.productVAT,
                                         productRoundable: self.switchProductRoundableOption.isOn ? 1 : 0,
                                         payerName: 0,  //there was a PayerName: "" before
                    billTip: 10)
                self.order.append(newOrderLine)
                SVProgressHUD.dismiss(withDelay: 2)
                self.performSegue(withIdentifier: "unwindSegueProduct2Menu", sender: self)
            }
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true)
        
        
        
    }
    
    @IBAction func actionQtyStepper(_ sender: UIStepper) {
        labelQty.text = String(Int(sender.value))
    }
}

//MARK: - UIPickerViewDataSource Methods

extension ProductVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    // picker options
    func numberOfComponents(in ProductPickerView: UIPickerView) -> Int    {
        return 1
        
    }
    
    func pickerView(_ ProductPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return listOfProductOptionsForPickerView[row]
        
    }
    
    func pickerView(_ ProductPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listOfProductOptionsForPickerView.count
        
    }
    
    func pickerView(_ ProductPickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        pickerViewCurrentValue = listOfProductOptions[row]
        if let PickedPrice = listOfOptionsAndPrices[pickerViewCurrentValue] {
            price = PickedPrice
        }
    }
    
}
