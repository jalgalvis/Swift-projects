//
//  ProductCell.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 4/10/17.
//  Copyright © 2017 Juan Alejandro Galvis. All rights reserved.
//

import UIKit

class ReusableCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    
    //MARK: Properties

    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDefaultOption: UILabel!
    @IBOutlet weak var productQty: UILabel!
    @IBOutlet weak var productQtyStepper: UIStepper!
    @IBOutlet weak var totalPrice: UILabel!
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPhoto: UIImageView!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var pickerOptions: UIPickerView!
    var pickerData: Array<String>!
    
    override func awakeFromNib() {
        if self.pickerOptions != nil{
            self.pickerData = Array<String>()
            self.pickerOptions.delegate = self
            self.pickerOptions.dataSource = self
        }
        super.awakeFromNib()
        
        
        // MARK: - Picker View delegate methods
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ ProductPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return pickerData[row]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    //   TODO: Change font size and text alignment in UIPickerView
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 16)
            pickerLabel?.textAlignment = .right
            pickerLabel?.adjustsFontSizeToFitWidth = true
            pickerLabel?.minimumScaleFactor = 0.7
        }
        pickerLabel?.text = pickerData[row]
        
        return pickerLabel!
    }
    
    
    

}
