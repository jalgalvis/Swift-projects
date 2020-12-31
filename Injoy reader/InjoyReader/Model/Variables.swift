import UIKit

//MARK: - Global Variables

var productListGlobal = [Product]()    //Array with MenuList sent from Server

//MARK: - enums

enum networkingAction {
    case order
    case bill
    case round
    case sessionStatus
    case orders
    case clearRound
    case clearPendigBill
    case session
}



