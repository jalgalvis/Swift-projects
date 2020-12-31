//
//  Product.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation
import UIKit

class Product: Decodable {
    
    //MARK: Properties
    
    var productID: Int = 0
    var productName: String = ""
    var productPhoto: String = ""
    var photo: UIImage {
        let decodedData = Data(base64Encoded: productPhoto, options: .ignoreUnknownCharacters)
        return UIImage(data: decodedData!)!
    }
    var productOptionPrice: [String:Int] = ["":0]
    var productDescription: String = ""
    var productKind: String = ""
    var productRoundable: Int = 0
    var roundableFlag: Bool {
        return productRoundable == 1
    }
    var popular: Int = 0
    var popularIndicator: Bool {
        return popular == 1
    }
    var offer: Int = 0
    var offerIndicator: Bool {
        return offer == 1
    }
    var productVAT: Int = 0
    
    //MARK: Initalization

    
    convenience init (productID: Int, productName: String, productPhoto: String, productOptionPrice: [String:Int], productDescription: String, productKind: String, productRoundable: Int, popular: Int, offer: Int, productVAT: Int) {
        self.init()
    }
    
    //MARK: Methods
    
}

