//
//  OrderSummary.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation

//MARK: - Order class Decodable


class Order : Decodable {
    
    //MARK: Properties
    
    var sessionID: String = ""
    var orderID: String
    var productID: Int
    var productName: String
    var productOptionPrice: [String:Int]
    var productDefaultOption: String
    var productKind: String
    var productQty: Int
    var productVAT: Int
    var productRoundable : Int
    var productRoundableFlag: Bool {
        return productRoundable == 1
    }
    var payerName: Int
    var billTip: Int
    
    //MARK: Initialization
    
    init(sessionID: String, orderID: String, productID: Int, productName: String, productOptionPrice: [String:Int], productDefaultOption: String, productKind: String, productQty: Int, productVAT: Int, productRoundable: Int, payerName: Int, billTip: Int) {
        
        
        
        self.sessionID = sessionID
        self.orderID = orderID
        self.productID = productID
        self.productName = productName
        self.productOptionPrice = productOptionPrice
        self.productDefaultOption = productDefaultOption
        self.productKind = productKind
        self.productQty = productQty
        self.productVAT = productVAT
        self.productRoundable = productRoundable
        self.payerName = payerName
        self.billTip = billTip
    }
    
}

//MARK: - Order class Encodable

extension Order : Encodable {
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(productID, forKey: .productID)
        try container.encode(productDefaultOption, forKey: .productDefaultOption)
        try container.encode(productQty, forKey: .productQty)
        try container.encode(payerName, forKey: .payerName)
        try container.encode(billTip, forKey: .billTip)
    }
}
