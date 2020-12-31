//
//  RestaurantMenuVC.swift
//
//  Created by Juan Alejandro Galvis on 14/8/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit
import SVProgressHUD
import MapKit




class selectOptionView: UIView {
    // for touches in a UIview
    override func touchesBegan(_ touches: (Set<UITouch>?), with event: UIEvent!) {
        let touch = touches?.first
        print(touch?.location(in: superview) ?? 0)
        
    }
}




class RestaurantMenuVC: UIViewController {
    
    
    @IBOutlet weak var pickerViewOptions: UIPickerView!
    @IBOutlet weak var tableViewPortions: UITableView!
    var categoriesPortionPositionInTable = [[PortionClass]]()
    var restaurantCategories = [CategoryClass]()
    var optionList = [OptionClass]()
    var portionList = [PortionClass]()
    var customerList = [Customer]()
    var pickerViewOptionsArray = [Int]()
    let currentRestaurantId = 21

    
    
    
    
    
    var restaurantOptions = [Int : OptionClass]()
    var restaurantOptionsArray = [String]()
    var order = [OrderClass]()
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let currentLocation = CLLocationCoordinate2D(latitude: 4.732354000, longitude: -74.05297200)
        
        let rangeArea = 0.004
        
        let latToNorth = currentLocation.latitude + rangeArea
        let latToSouth = currentLocation.latitude - rangeArea
        let lonToEast = currentLocation.longitude + rangeArea
        let lonToWest = currentLocation.longitude - rangeArea
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let jsonUrlString = "https://www.zmrcolombia.com/tableViewJson/restaurantOptionPortion.php?latToSouth=\(latToSouth)&latToNorth=\(latToNorth)&lonToWest=\(lonToWest)&lonToEast=\(lonToEast)"
        let request = URLRequest(url: URL(string: jsonUrlString)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard let data = data else { return }
            do {
                self.customerList = try JSONDecoder().decode([Customer].self, from: data)
                semaphore.signal()
                
            } catch let jsonErr { print("Error serializing json:", jsonErr)}
        }
        task.resume()
        
        let timeout = DispatchTime.now() + .seconds(20)
        if semaphore.wait(timeout: timeout) == .timedOut {
            print("error") // if the process take too much time returns a blank array, which is a flag to start again.
        }

        let customerListDict = Dictionary(grouping: customerList.sorted(by: {$0.id < $1.id}), by: { $0.id}).mapValues { $0.first! }
        
        
        if customerListDict[currentRestaurantId]?.options != nil {
            optionList = (customerListDict[currentRestaurantId]?.options!)!
        }
        
        if customerListDict[currentRestaurantId]?.portions != nil {
            portionList = (customerListDict[currentRestaurantId]?.portions!)!
        }
        
        restaurantOptions = Dictionary(grouping: optionList.sorted(by: {$0.id < $1.id}), by: { $0.id}).mapValues { $0.first! }
        restaurantOptionsArray = optionList.sorted(by: {$0.id < $1.id}).map({$0.name})
        
        
        pickerViewOptionsArray = Array(restaurantOptions.keys).sorted(by: {$0 < $1})
        let currentOption = pickerViewOptionsArray[pickerViewOptions.selectedRow(inComponent: 0)]
        createArray(currentOption: currentOption)
        
    }
    
    func createArray(currentOption: Int) {
            let restaurantPortions = portionList.filter({$0.optionId == currentOption})
        // select unique categories in restaurant menu
        let categoryToFilter = Set(Array(restaurantPortions.map({$0.categoryId})))
        
        restaurantCategories = [CategoryClass]()
        categoriesPortionPositionInTable = [[PortionClass]]()
        restaurantCategories = categoryList.values.filter ({categoryToFilter.contains($0.id)}).sorted(by: {$0.id < $1.id})
        
        // create an array for tableview
        
        for category in restaurantCategories
        {
            let rawPortion = restaurantPortions.filter {$0.categoryId == category.id}.sorted(by: {$0.id < $1.id})
            categoriesPortionPositionInTable.append(rawPortion)
        }
        
        dump(categoriesPortionPositionInTable)
    }
    
    @IBAction func confirmOrderButton(_ sender: UIButton) {
        var validOrder = true
        var pendingPortions = ""
        
        restaurantCategories.forEach { (category) in
            if order.filter ({$0.categoryId == category.id}).count < category.minPortions {
                validOrder = false
                pendingPortions += " \(category.name)"
            }
        }
        
        
        
        if validOrder {
            SVProgressHUD.showSuccess(withStatus: "Orden confirmada")
            SVProgressHUD.dismiss(withDelay:2)
            dump(order)
            order.forEach({
                print("Portion: \(portionList[$0.portionId].name ) - id: \($0.portionId)")
                print("Category: \(categoryList[$0.categoryId]!.name) - id: \($0.categoryId)")
                print("Option \(optionList[portionList[$0.portionId].optionId].name) - id: \(portionList[$0.portionId].optionId)")
            })
        } else {
            SVProgressHUD.showInfo(withStatus: "Por favor seleccionar\(pendingPortions)")
            SVProgressHUD.dismiss(withDelay:3)
        }
        
        
    }
    
}

extension RestaurantMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfPortions = categoriesPortionPositionInTable[section]
        return numberOfPortions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        let portionName = categoriesPortionPositionInTable[indexPath.section][indexPath.row].name
        let portionId = categoriesPortionPositionInTable[indexPath.section][indexPath.row].id
        cell.textLabel?.text = portionName
        cell.accessoryType = order.filter({$0.portionId == portionId}).count == 0 ? .none : .checkmark
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoriesPortionPositionInTable.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titleName = restaurantCategories[section].name
        return titleName
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let portionId = categoriesPortionPositionInTable[indexPath.section][indexPath.row].id
        let categoryId = restaurantCategories[indexPath.section].id
        let maxPortion = restaurantCategories[indexPath.section].maxPortions
        
        // check if the portion is checked or nor (exist or not in the order list)
        if order.filter({$0.portionId == portionId}).count == 0 {
            // check the maximum number of portions per portion category, if it doesn't reach the maximum add it to the order
            if order.filter({$0.categoryId == categoryId}).count < maxPortion {
                let orderElement = OrderClass(customerId: 0, id: portionId, categoryId: categoryId)
                order.append(orderElement)
                //                in case it reaches the maximum amount a message is displayed
            } else {
                if maxPortion == 1 {
                    SVProgressHUD.showError (withStatus: "Máximo \(maxPortion) porción")
                    
                } else {
                    SVProgressHUD.showError (withStatus: "Máximo \(maxPortion) porciones")
                }
                SVProgressHUD.dismiss(withDelay:1)
            }
            
            
        } else {
            if let orderElement = order.index(where: { $0.portionId == portionId}) {
                order.remove(at: orderElement)
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
    
}

extension RestaurantMenuVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return restaurantOptionsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return restaurantOptions[pickerViewOptionsArray[row]]?.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currentOption = restaurantOptions[pickerViewOptionsArray[row]]?.id
        createArray(currentOption: currentOption!)
        tableViewPortions.reloadData()
    }
    
}
