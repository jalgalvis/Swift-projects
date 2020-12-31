//: Playground - noun: a place where people can play

import UIKit

struct Person {
    let name:String
    let position:Int
}

let persons = [Person(name: "Franz", position: 1),
               Person(name: "Heinz", position: 2),
               Person(name: "Hans", position: 1)]

let x = Dictionary(grouping: persons.filter({$0.position == 2}), by: { $0.position}).mapValues { $0.first! }
dump(x)


let y = Array(x.values)

dump(y)



