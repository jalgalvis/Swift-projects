import UIKit


class Order {
    var productId : Int
    var userId : Int
    var qty : Int
    init(productId: Int, userId: Int, qty: Int) {
        self.productId = productId
        self.userId = userId
        self.qty = qty
    }
}


    var arrayOfOrders = [Order(productId: 1, userId: 1, qty: 5),
                         Order(productId: 1, userId: 2, qty: 10),
                         Order(productId: 2, userId: 1, qty: 20),
                         Order(productId: 2, userId: 2, qty: 5),
                         Order(productId: 3, userId: 3, qty: 15),
                         Order(productId: 2, userId: 1, qty: 10),
                         Order(productId: 3, userId: 1, qty: 5),
                         Order(productId: 1, userId: 3, qty: 15),]

dump(arrayOfOrders.sorted(by: {$0.productId < $1.productId}).sorted(by: {$0.userId < $1.userId}))

let totals:[Order] = arrayOfOrders.reduce(into: []) { (result, order) in
    if let last = result.last,
        last.productId == order.productId && last.userId == order.userId {
        result[result.count-1] = Order(productId: last.productId, userId: last.userId, qty: last.qty + order.qty)
    } else {
        result.append(order)
    }
}


//dump(totals)
