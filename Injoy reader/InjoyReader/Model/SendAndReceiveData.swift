import Foundation


// MARK: - Receive Data from Server Functions


func receiveDataFromServerProducts (placeID : Int) -> [Product]{
    let semaphore = DispatchSemaphore(value: 0)
    var productList = [Product]()
    let jsonUrlString = "https://www.injoy.com.co/InjoyAppIos/DbPortfolio.php?PID=\(placeID)"
    let request = URLRequest(url: URL(string: jsonUrlString)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let data = data else { return }
        do {
            productList = try JSONDecoder().decode([Product].self, from: data)
            semaphore.signal()
        } catch let jsonErr { print("Error serializing json:", jsonErr)}
    }
    task.resume()
    let timeout = DispatchTime.now() + .seconds(5)
    if semaphore.wait(timeout: timeout) == .timedOut {
    }
    return productList
}

