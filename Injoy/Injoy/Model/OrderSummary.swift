//
//  OrderSummary.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 5/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation

    //MARK: - Properties


class OrderSummary {
    
    var orderID: String
    var orderTotalPrice: Int
    
    //MARK: - Initialization
    
    init(orderID: String, orderTotalPrice: Int) {
        self.orderID = orderID
        self.orderTotalPrice = orderTotalPrice
    }
}
