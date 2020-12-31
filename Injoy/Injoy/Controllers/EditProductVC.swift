import UIKit
import SVProgressHUD

class EditProductVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var buttonProduct: UIButton!
    @IBOutlet weak var pickerProduct: UIPickerView!
    @IBOutlet weak var labelQty: UILabel!
    @IBOutlet weak var ImageViewProductImage: UIImageView!
    @IBOutlet weak var switchProductRoundable: UISwitch!
    @IBOutlet weak var viewRoundBackground: UIView!
    @IBOutlet weak var stepperProductQty: UIStepper!
    
    var productOptions: [String] = []
    var productOptionsPV: [String] = []
    var productOptionPrice: [String:Int] = [:]
    var pickerViewValue: String = ""
    var productKind: String = ""
    var productID: Int = 0
    var productVAT: Int = 0
    var price: Int = 0
    var selectedProduct: Int?
    var orderLineToModify : Order?
    let sessionInfo = Session.getsessionRealm()
    
    
    //MARK: Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let orderLine = orderLineToModify {
            switchProductRoundable.onTintColor = sessionInfo.placeColor
            viewRoundBackground.backgroundColor = sessionInfo.placeColor.withAlphaComponent(0.8)
            view.tintColor = sessionInfo.placeColor
            buttonProduct.backgroundColor = sessionInfo.placeColor
            
            self.title = orderLine.productName
            
            DispatchQueue.main.async {
                self.ImageViewProductImage.image = UIImage()
                self.ImageViewProductImage.image = productList[orderLine.productID]?.photo
            }
            
            labelQty.text = String(orderLine.productQty)
            stepperProductQty.value = Double(orderLine.productQty)
            
            if let orderLinesPOP = productList[orderLine.productID] {
                productOptionPrice = orderLinesPOP.productOptionPrice
            }
            
            
            // Sort dictionary of Options from cheapest to Most Expensive
            let ProductOptionPriceSorted = productOptionPrice.sorted(by: { $0.value < $1.value })
            
            // Array for PickerView
            productOptionsPV = ProductOptionPriceSorted.map { $0.key }
            productOptions = productOptionsPV
            
            for (index,element) in productOptionsPV.enumerated() {
                productOptionsPV[index] += "   $ \(String(format: "%d", locale: Locale.current, productOptionPrice[element]!))"
            }
            pickerViewValue = productOptions[0]
            price = productOptionPrice[pickerViewValue]!
            productKind = orderLine.productKind
            switchProductRoundable.isOn = orderLine.productRoundableFlag
            productID = orderLine.productID
            productVAT = orderLine.productVAT
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        for index in 0...productOptionsPV.count - 1 {
            if productOptions[index] == orderLineToModify?.productOptionPrice.first?.key {
                pickerProduct.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    //MARK: Actions
    
    @IBAction func buttonActionOrderProduct(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Desea actualizar \(self.title ?? "")?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        
        let destroyAction = UIAlertAction(title: "Actualizar", style: .destructive) { action in
            self.orderLineToModify?.productOptionPrice = [self.pickerViewValue : self.price]
            self.orderLineToModify?.productQty = Int(self.labelQty.text!)!
            self.orderLineToModify?.productRoundable = self.switchProductRoundable.isOn ? 1 : 0
            
            
            // Alert Product Added
            SVProgressHUD.showSuccess(withStatus: "Producto Actualizado")
            SVProgressHUD.dismiss(withDelay: 2)
            self.navigationController?.popViewController(animated: true)
            
        }
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true) {
        }
    }
    
    @IBAction func stepperActionQty(_ sender: UIStepper)
    {
        labelQty.text = String(sender.value)
    }
}

//MARK: - UIPickerViewDelegate Methods

extension EditProductVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // picker options
    func numberOfComponents(in ProductPickerView: UIPickerView) -> Int    {
        return 1   }
    
    func pickerView(_ ProductPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return productOptionsPV[row]    }
    
    func pickerView(_ ProductPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return productOptionsPV.count  }
    
    func pickerView(_ ProductPickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        pickerViewValue = productOptions[row]
        if let PickedPrice = productOptionPrice[pickerViewValue] {
            price = PickedPrice
        }
        
    }
}
