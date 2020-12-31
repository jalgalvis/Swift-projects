//
//  OrderSummary.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation
import UIKit


//MARK: - Order class Decodable


class Order {
    
    //MARK: Properties
    
    var productID: Int
    var productName: String
    var productOptionPrice: [String:Int]
    var productQty: Int
    var productImage: UIImage?
    
    //MARK: Initialization
    
    init(productID: Int, productName: String, productOptionPrice: [String:Int], productQty: Int, productImage: UIImage) {
        
        
        
        self.productID = productID
        self.productName = productName
        self.productOptionPrice = productOptionPrice
        self.productQty = productQty
        self.productImage = productImage
    }
    
}
