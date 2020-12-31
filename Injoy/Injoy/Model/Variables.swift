import UIKit

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

enum SessionStatus1 : Int {
    case aciveNotPendingBill = 1
    case active = 2
    case activePendigBill = 3
}



// 1 means that Session is active but there is not a pending bill (bill payed)
// option 1 -> app doesn't try to use the same userEmail
// 2 means that Session is active but there is not a pending bill (not orders yet)
// option 2 -> app try to enter using the same userEmail (but ask if so)
// 3 means that Session is active and there is a pending bill
// option 3 -> app enters with userEmail without asking
