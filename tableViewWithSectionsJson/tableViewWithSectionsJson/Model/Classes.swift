//
//  Customer.swift
//
//
//  Created by Juan Alejandro Galvis on 8/15/18.
//

import Foundation
import UIKit

var defalultUserOptions = optionsGroupX()

class PortionClass : Codable {
    var id = Int()
    var name = String()
    var categoryId = Int()
    var restaurantId = Int()
    var optionId = Int()
    
    convenience init (id: Int, name: String, categoryId: Int, restaurantId: Int, optionId: Int){
        self.init()
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.restaurantId = restaurantId
        self.optionId = optionId
    }
}

class CategoryClass {
    var id = Int()
    var name = String()
    var maxPortions = Int()
    var minPortions = Int()
    convenience init(id: Int, name: String, minPortions:Int, maxPortions: Int) {
        self.init()
        self.id = id
        self.name = name
        self.minPortions = minPortions
        self.maxPortions = maxPortions
    }
}

class OptionClass : Codable {
    var id = Int()
    var name = String()
    var restaurantId = Int()
    convenience init(id: Int, name: String, restaurantId: Int ) {
        self.init()
        self.id = id
        self.name = name
        self.restaurantId = restaurantId
    }
}




class OrderClass {
    var customerId = Int()
    var portionId = Int()
    var categoryId = Int()
    convenience init(customerId: Int, id: Int, categoryId: Int) {
        self.init()
        self.customerId = customerId
        self.portionId = id
        self.categoryId = categoryId
    }
}

enum optionsGroup: Int {
    case eatIn = 0
    case takeAway = 1
    case delivery = 2
    case chicken = 3
    case beef = 4
    case pork = 5
    case fish = 6
    case seaFood = 7
    case vegetarian = 8
}

class optionsGroupX {
    var eatIn = true
    var takeAway = true
    var delivery = true
    var chicken = true
    var beef = true
    var pork = true
    var fish = true
    var seaFood = true
    var vegetarian = true
}



class Customer : Codable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var imageURL: URL
    var image: UIImage {
        if let img = UIImage(url: imageURL) {
            return img
        } else {
            return UIImage(named: "placeHolder")!
        }
        
    }
    var distance : Int?
    var routePoints : String?
    var rating : Double
    var portions : [PortionClass]?
    var options : [OptionClass]?
    var eatInOption : Bool
    var takeAwayOption : Bool
    var deliveryOption : Bool
    var chickenOption : Bool
    var beefOption : Bool
    var porkOption : Bool
    var fishOption : Bool
    var seaFoodOption : Bool
    var vegetarianOption : Bool
    
    
    
    init (id: Int, name: String, latitude: Double, longitude: Double, imageURL: URL, rating: Double, eatInOption: Bool, takeAwayOption: Bool, deliveryOption: Bool,chickenOption: Bool, beefOption: Bool, porkOption: Bool, fishOption: Bool, seaFoodOption: Bool, vegetarianOption: Bool) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
        self.rating = rating
        self.eatInOption = eatInOption
        self.takeAwayOption = takeAwayOption
        self.deliveryOption = deliveryOption
        self.chickenOption = chickenOption
        self.beefOption = beefOption
        self.porkOption = porkOption
        self.fishOption = fishOption
        self.seaFoodOption = seaFoodOption
        self.vegetarianOption = vegetarianOption
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case imageURL
        case distance
        case routePoints
        case rating
        case portions
        case options
        case eatInOption
        case takeAwayOption
        case deliveryOption
        case chickenOption
        case beefOption
        case porkOption
        case fishOption
        case seaFoodOption
        case vegetarianOption
    }
}




