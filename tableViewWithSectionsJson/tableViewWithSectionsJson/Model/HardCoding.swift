//
//  HardCoding.swift
//
//  Created by Juan Alejandro Galvis on 9/5/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import Foundation
import UIKit

let categoryList : [Int:CategoryClass] = {
    
    let categoriesReceived = [CategoryClass(id : 1, name : "SOPA", minPortions : 2, maxPortions : 3),CategoryClass(id : 2, name : "PRINCIPIO", minPortions : 0, maxPortions : 1),CategoryClass(id : 3, name : "PROTEINA", minPortions : 1, maxPortions : 3),CategoryClass(id : 400, name : "CARBOHIDRATO", minPortions : 0, maxPortions : 2),CategoryClass(id : 5, name : "ENSALADA", minPortions : 0, maxPortions : 1),CategoryClass(id : 6, name : "BEBIDA", minPortions : 1, maxPortions : 2),]
    let categoriesDictionary = Dictionary(grouping: categoriesReceived, by: { $0.id}).mapValues { $0.first! }
    
    return categoriesDictionary
}()




    


