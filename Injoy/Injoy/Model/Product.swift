//
//  Product.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

let imageCache = NSCache<NSString, UIImage>()


class Product: Codable {
    
    //MARK: Properties
    
    var productID: Int = 0
    var productName: String = ""
    var productPhotoURL: String = ""
    var photo: UIImage {
        if let imageFromCache = imageCache.object(forKey: productPhotoURL as NSString) {
            return imageFromCache
        }
        if let image = UIImage(url: URL(string: productPhotoURL)) {
            imageCache.setObject(image, forKey: productPhotoURL as NSString)
            return image
        } else {
            return UIImage(named: "Meal")!
        }
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

    
    convenience init (productID: Int, productName: String, productPhotoURL: String, productOptionPrice: [String:Int], productDescription: String, productKind: String, productRoundable: Int, popular: Int, offer: Int, productVAT: Int) {
        self.init()
    }
    
    //MARK: Methods
    
}

