import Foundation
import SVProgressHUD

// MARK: - Send Data to Server Functions

var URL_Injoy = "https://www.zmrcolombia.com/"

func sendDataToServer (action : networkingAction, dataToSend: Any = "", sessionID: String = "", Option: Int = 0) {
    let semaphore = DispatchSemaphore(value: 0)
    var encodedData = Data()
    var jsonUrlString = ""
    do {
        switch action {
        case .sessionStatus:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbSessionStatus.php?ID=\(sessionID)&OP=\(Option)"
            encodedData = "sessionID=\(sessionID)".data(using: String.Encoding.utf8)!
            
        case .orders:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/orderIn.php"
            encodedData = try JSONEncoder().encode(dataToSend as! [Order])
            
        case .clearRound:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbClear.php?ID=\(sessionID)&OP=2"
            encodedData = "sessionID=\(sessionID)".data(using: String.Encoding.utf8)!
            
        case .clearPendigBill:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbClear.php?ID=\(sessionID)&OP=1"
            encodedData = "sessionID=\(sessionID)".data(using: String.Encoding.utf8)!
            
        case .session:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/CreateSession.php"
            encodedData = try JSONEncoder().encode(dataToSend as! SessionToSend)
            
        default:
            print(action)
        }
    } catch let jsonErr { print("Error serializing json:", jsonErr)}
    var request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
    request.httpBody = encodedData
    request.httpMethod = "POST"// Compose a query string
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        if error != nil {
            print("error=\(String(describing: error))")
            return
        }
        semaphore.signal()

    }
    task.resume()
    let timeout = DispatchTime.now() + .seconds(5)
    if semaphore.wait(timeout: timeout) == .timedOut {
        print("Send Session Failed")
    } else {
        print("Send Session Sucessful")
    }
}


func sendDataToServer1 (action : networkingAction, dataToSend: Any = "", sessionID: String = "", Option: Int = 0, completion: @escaping () -> Void) {
    var encodedData = Data()
    var jsonUrlString = ""
    do {
        switch action {
        case .sessionStatus:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbSessionStatus.php?ID=\(sessionID)&OP=\(Option)"
            encodedData = "sessionID=\(sessionID)".data(using: String.Encoding.utf8)!
            
        case .orders:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/orderIn.php"
            encodedData = try JSONEncoder().encode(dataToSend as! [Order])
            
        case .clearRound:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbClear.php?ID=\(sessionID)&OP=2"
            encodedData = "sessionID=\(sessionID)".data(using: String.Encoding.utf8)!
            
        case .clearPendigBill:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbClear.php?ID=\(sessionID)&OP=1"
            encodedData = "sessionID=\(sessionID)".data(using: String.Encoding.utf8)!
            
        case .session:
            jsonUrlString = "\(URL_Injoy)InjoyAppIos/CreateSession.php"
            encodedData = try JSONEncoder().encode(dataToSend as! SessionToSend)
            
        default:
            print(action)
        }
    } catch let jsonErr { print("Error serializing json:", jsonErr)}
    var request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
    request.httpBody = encodedData
    request.httpMethod = "POST"// Compose a query string
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        if error != nil {
            print("error=\(String(describing: error))")
        }
        completion()
    }
    task.resume()
}
// MARK: - Receive Data from Server Functions


func receiveDataFromServerPlaceName (placeID : Int) -> (data: String,succesful: Bool) {
    let semaphore = DispatchSemaphore(value: 0)
    var placeNameArray = [[String:String]]()
    let jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbSessionPlace.php?ID=\(placeID)&OP=2"
    let request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let data = data else { return }
        do {
            placeNameArray = try JSONDecoder().decode([[String:String]].self, from: data)
            semaphore.signal()
        } catch let jsonErr { print("Error serializing json:", jsonErr)}
    }
    task.resume()
    let timeout = DispatchTime.now() + .seconds(5)
    if semaphore.wait(timeout: timeout) == .timedOut {
        return ("",false)
    } else {
        return (placeNameArray[0]["placeName"]!,true)
    }
    
    
}

func receiveDataFromServerProducts (placeID : Int, completion: @escaping ([Product]) -> Void) {
    var productList = [Product]()
    let jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbPortfolio.php?PID=\(placeID)"
    let request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let data = data else { return }
        do {
            productList = try JSONDecoder().decode([Product].self, from: data)
            completion (productList)
        } catch let jsonErr { print("Error serializing json:", jsonErr)}
    }
    task.resume()
}

func receiveDataFromServerGeneralInfo (placeID : Int, completion: @escaping (String,String) -> Void) {
    struct placeInfo : Decodable {
        var placeColor : String = ""
        var backgroundImage : String = ""
    }
    var placeInfoArrayDecodable = [placeInfo]()
    let jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbSessionPlace.php?ID=\(placeID)&OP=1"
    let request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let data = data else { return }
        do {
            placeInfoArrayDecodable = try JSONDecoder().decode([placeInfo].self, from: data)
            let backgroundImage = placeInfoArrayDecodable[0].backgroundImage
            let placeColor = placeInfoArrayDecodable[0].placeColor
            completion (backgroundImage, placeColor)
        } catch let jsonErr {
            print("Error serializing json:", jsonErr)
            completion ("", "")
        }
    }
    task.resume()
    
    
}



func receiveDataFromServerSessionStatus (sessionID : String) -> Int {
    let semaphore = DispatchSemaphore(value: 0)
    var sessionStatusArray = [[String:Int]]()
    
    let jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbSessionPlace.php?ID=\(sessionID)&OP=3"
    let request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let data = data else { return }
        do {
            sessionStatusArray = try JSONDecoder().decode([[String:Int]].self, from: data)
            semaphore.signal()
        } catch let jsonErr { print("Error serializing json:", jsonErr)}
    }
    task.resume()
    let timeout = DispatchTime.now() + .seconds(5)
    if semaphore.wait(timeout: timeout) == .timedOut {
        return 0
    } else {
        return sessionStatusArray[0]["sessionStatus"]!
    }
    
    
}



func receiveDataFromServerOrderClass (sessionID: String, orderID: String = "", action: networkingAction) -> [Order] {
    let semaphore = DispatchSemaphore(value: 0)
    var jsonUrlString = ""
    switch action {
    case .bill:
        jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbBillRoundOrder.php?ID=\(sessionID)&OP=1"
    case .round:
        jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbBillRoundOrder.php?ID=\(sessionID)&OP=2"
    case .order:
        jsonUrlString = "\(URL_Injoy)InjoyAppIos/DbBillRoundOrder.php?SID=\(sessionID)&ID=\(orderID)&OP=3"
    default :
        print(action)
        
    }
    var orders = [Order]()
    let request = URLRequest(url: URL(string: jsonUrlString)!, timeoutInterval: 20)
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let data = data else { return }
        do {
            orders = try JSONDecoder().decode([Order].self, from: data)
            semaphore.signal()
            
        } catch
            let jsonErr { print("Error serializing json:", jsonErr)}
    }
    task.resume()
    let timeout = DispatchTime.now() + .seconds(5)
    if semaphore.wait(timeout: timeout) == .timedOut {
    }
    return orders
}
