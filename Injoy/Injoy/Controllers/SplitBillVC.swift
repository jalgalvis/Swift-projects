import UIKit
import SVProgressHUD

// MARK: -  UIViewController

class SplitBillVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var tableViewTVBill: UITableView!
    @IBOutlet weak var tableViewBillPerPerson: UITableView!
    @IBOutlet weak var labelTotalBill: UILabel!
    @IBOutlet weak var labelSubTotalBill: UILabel!
    @IBOutlet weak var labelTipValue: UILabel!
    @IBOutlet weak var labelTip: UILabel!
    @IBOutlet weak var sliderTip: UISlider!
    @IBOutlet weak var segmentedControlNumberOfPeople: UISegmentedControl!
    @IBOutlet weak var stepperNumberOfPeopleStepper: UIStepper!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonPartialBill: UIButton!
    @IBOutlet weak var labelPlaceNameBill: UILabel!
    @IBOutlet weak var labelDateBill: UILabel!
    @IBOutlet weak var viewSplitedBill : UIView!
    
    var indexPathToUpdate: Int = 0
    var arraySplitBill = [Order]()
    var arrayNotSplited = [Order]()
    var originalBill = [Order]()
    var arrayTips = [Int]()
    var arrayFromToTable = [Int:Int]()
    let sessionInfo = Session.getsessionRealm()

    
    let maximumNumberOfPayers = 5
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTVBill.dataSource = self
        tableViewBillPerPerson.dataSource = self
        tableViewTVBill.dragInteractionEnabled = true
        tableViewTVBill.dragDelegate = self
        tableViewBillPerPerson.dragDelegate = self
        tableViewTVBill.dropDelegate = self
        tableViewBillPerPerson.dropDelegate = self
        labelPlaceNameBill.text = sessionInfo.placeName
        labelDateBill.text = "\(sessionInfo.deCodeDate(ExpectedFormat: "MMM dd yyyy", CodedDate: sessionInfo.sessionID))"
        buttonClear.backgroundColor = sessionInfo.placeColor
        buttonPartialBill.backgroundColor = sessionInfo.placeColor
        view.tintColor = sessionInfo.placeColor
        stepperNumberOfPeopleStepper.maximumValue = Double(maximumNumberOfPayers)
        originalBill = receiveDataFromServerOrderClass(sessionID: sessionInfo.sessionID, action: .bill)
        arraySplitBill = originalBill.filter{$0.payerName == 0}
        arrayNotSplited = arraySplitBill
        
        for index in 0...arraySplitBill.count - 1 {
            arrayFromToTable[index] = index
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectNumberOfPayers(maxPayers: maximumNumberOfPayers)
    }
    
    
    func selectNumberOfPayers(maxPayers: Int) {
        segmentedControlNumberOfPeople.removeAllSegments()
        let alertController = customUIAlertView(title: nil, message: "En cuantas cuentas desea dividir", preferredStyle: .alert)
        for numberOfPayers in 1...maxPayers {
            let action = UIAlertAction(title: String(numberOfPayers), style: .default) { _ in
                for index in 1...numberOfPayers {
                    self.segmentedControlNumberOfPeople.insertSegment(withTitle: String(index), at: index-1, animated: false)
                    self.arrayTips += [10]
                }
                self.segmentedControlNumberOfPeople.selectedSegmentIndex = 0
                self.stepperNumberOfPeopleStepper.value = Double(numberOfPayers)
            }
            alertController.addAction(action)
        }
        self.present(alertController, animated: true) {
        }
    }
    
    //MARK: Acions

    
    @IBAction func stepperActionNumberOfPeople(_ sender: UIStepper) {
        
        if Int(sender.value) > segmentedControlNumberOfPeople.numberOfSegments {
            // add a new segment
            arraySplitBill.filter {$0.payerName != 0 && $0.payerName > segmentedControlNumberOfPeople.selectedSegmentIndex + 1}.forEach{
                $0.payerName += 1
            }
            
            segmentedControlNumberOfPeople.insertSegment(withTitle: String(Int(sender.value)), at: Int(sender.value) - 1, animated: true)
            segmentedControlNumberOfPeople.selectedSegmentIndex += 1
            tableViewBillPerPerson.reloadData()
            arrayTips.insert(10, at: segmentedControlNumberOfPeople.selectedSegmentIndex)
            updateSubtotals()
        } else {
            let indexProductToUpdate = segmentedControlNumberOfPeople.selectedSegmentIndex
            
            //change payername to 0 to the deleted products in the deleted segment
            
            arraySplitBill.filter {$0.payerName == indexProductToUpdate + 1}.forEach {$0.payerName = 0}
            //delete tip of the deleted segment
            arrayTips.remove(at: indexProductToUpdate)
            
            //change the rest of the segments to avoid showing empty in the deleted segment
            
            
            arraySplitBill.filter { $0.payerName != 0 && $0.payerName > segmentedControlNumberOfPeople.selectedSegmentIndex + 1}.forEach{
                $0.payerName -= 1
            }
            
            //Create all segments starting by 1
            let Segments = segmentedControlNumberOfPeople.numberOfSegments - 1
            segmentedControlNumberOfPeople.removeAllSegments()
            for index in 1...Segments {
                segmentedControlNumberOfPeople.insertSegment(withTitle: String(index), at: index - 1, animated: true)
            }
            
            //select the previous segment
            if indexProductToUpdate == 0 {
                segmentedControlNumberOfPeople.selectedSegmentIndex = 0
            } else {
                segmentedControlNumberOfPeople.selectedSegmentIndex = indexProductToUpdate - 1
            }
            
            arrayNotSplited.removeAll()
            arrayFromToTable.removeAll()
            var i = 0
            for Bill in 0...arraySplitBill.count - 1 {
                if arraySplitBill[Bill].payerName == 0 {
                    arrayNotSplited.append(arraySplitBill[Bill])
                    arrayFromToTable[i] = Bill
                    i += 1
                }
            }
            if tableViewTVBill.isHidden == true {
                tableViewTVBill.isHidden = false
                viewSplitedBill.slideXback(WidthToDecrease: 1/1.4, screenWidth: self.view.frame.size.width)
            }
            updateSubtotals()
            tableViewTVBill.reloadData()
            tableViewBillPerPerson.reloadData()
            buttonPartialBill.setTitle("Cuenta Parcial", for: .normal)
        }
    }
    
    @IBAction func buttonActionNumberOfPeople(_ sender: UISegmentedControl) {
        tableViewBillPerPerson.reloadData()
        tableViewTVBill.reloadData()
        updateSubtotals()
    }
    
    @IBAction func SliderActionTip(_ sender: UISlider) {
        arrayTips[segmentedControlNumberOfPeople.selectedSegmentIndex] = Int(sender.value)
        updateSubtotals()
    }
    
    func updateSubtotals(){
        
        let Bills = arraySplitBill.filter {$0.payerName == segmentedControlNumberOfPeople.selectedSegmentIndex + 1}
        
        
        let SubTotalBillInt = Bills.reduce(0) { $0 + ($1.productQty * ($1.productOptionPrice.first?.value)!) }
        labelSubTotalBill.text = "$ \(String(format: "%d", locale: Locale.current, SubTotalBillInt))"
        let tipRate = arrayTips.count > segmentedControlNumberOfPeople.selectedSegmentIndex ? arrayTips[segmentedControlNumberOfPeople.selectedSegmentIndex] : 0
        let TipValueInt: Int = Int(Double(SubTotalBillInt)/1.08 * Double(tipRate)/100)
        labelTipValue.text = "$ \(String(format: "%d", locale: Locale.current, TipValueInt))"
        labelTip.text = "Propina \(arrayTips[segmentedControlNumberOfPeople.selectedSegmentIndex])%"
        let TotalBillInt = SubTotalBillInt + TipValueInt
        labelTotalBill.text = "$ \(String(format: "%d", locale: Locale.current, TotalBillInt))"
        sliderTip.value = Float(arrayTips[segmentedControlNumberOfPeople.selectedSegmentIndex])
    }
    
    @IBAction func buttonActionClear(_ sender: UIButton) {
        if arrayFromToTable.count == 0 {
            tableViewTVBill.isHidden = false
            viewSplitedBill.slideXback(WidthToDecrease: 1/1.4, screenWidth: self.view.frame.size.width)
        }
        originalBill = receiveDataFromServerOrderClass(sessionID: sessionInfo.sessionID, action: .bill)
        arraySplitBill = [Order]()
        arrayNotSplited = [Order]()
        arrayFromToTable = [Int : Int]()
        
        arraySplitBill = originalBill.filter {$0.payerName == 0}
        
        arrayNotSplited = arraySplitBill
        
        for index in 0...arraySplitBill.count - 1 {
            arrayFromToTable[index] = index
        }
        tableViewTVBill.reloadData()
        tableViewBillPerPerson.reloadData()
        updateSubtotals()
        buttonClear.isHidden = true
        buttonPartialBill.isEnabled = false
        buttonPartialBill.setTitle("Cuenta Parcial", for: .normal)
        selectNumberOfPayers(maxPayers: maximumNumberOfPayers)

    }
    
    @IBAction func buttonActionCalculateBill(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Desea \(buttonPartialBill.titleLabel!.text!)?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        alertController.addAction(cancelAction)
        let destroyAction = UIAlertAction(title: "Aceptar", style: .destructive) { action in
            
            // Alert Confirm Bill
            
            SVProgressHUD.showSuccess(withStatus: "Cuenta procesada, será llevada en Breve")
            self.confirmBill()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "unwindSegueSplitBill2Checked", sender: self)
            }
        }
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
    
    func confirmBill() {
        if self.arrayFromToTable.count == 0 {
            sessionInfo.roundExistFlag = false
            sessionInfo.billExistFlag = false
            Session.updateRealm(newSession: sessionInfo)
            sessionInfo.status = 1
            Session.updateRealm(newSession: sessionInfo)
            sendDataToServer(action: .sessionStatus, sessionID: sessionInfo.sessionID, Option: 1)
            
        }
        sendDataToServer(action: .clearPendigBill, sessionID: sessionInfo.sessionID)
        self.arraySplitBill.filter { $0.payerName != 0 }.forEach {
            $0.billTip = self.arrayTips[$0.payerName - 1]
        }
        sendDataToServer(action: .orders, dataToSend: self.arraySplitBill)
    }
}

// MARK: -  UITableViewDataSource

extension SplitBillVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        if tableView == self.tableViewTVBill {
            count = arrayNotSplited.count
        }
        if tableView == self.tableViewBillPerPerson {
            count = arraySplitBill.filter ({$0.payerName == segmentedControlNumberOfPeople.selectedSegmentIndex + 1}).count
        }
        return count!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var Bills = [Order]()
        switch(tableView) {
        case self.tableViewTVBill:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SplitBillCell") as! ReusableCell
            let product = arrayNotSplited[indexPath.row]

            DispatchQueue.main.async {
                cell.productPhoto.image = UIImage()
                cell.productPhoto.image = productList[product.productID]?.photo
            }
            cell.productName.text = product.productName
            cell.productQty.text = String(product.productQty)
            cell.productPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * (product.productOptionPrice.first?.value)!))"
            cell.productDefaultOption.text = product.productOptionPrice.first?.key
            return cell
            
        // BillPerPerson
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BillPerPersonCell") as! ReusableCell
            for Bill in arraySplitBill where Bill.payerName == segmentedControlNumberOfPeople.selectedSegmentIndex + 1{
                Bills.append(Bill)
            }
            let product = Bills[indexPath.row]
            cell.productName.text = "\(String(product.productQty)) x \(product.productName)"
            cell.totalPrice.text = "$ \(String(format: "%d", locale: Locale.current, product.productQty * (product.productOptionPrice.first?.value)!))"
            return cell
        }
    }
}

// MARK: -  UITableViewDragDelegate

extension SplitBillVC: UITableViewDragDelegate {
    
    
    //     The `tableView(_:itemsForBeginning:at:)` method is the essential method
    //     to implement for allowing dragging from a table.
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        indexPathToUpdate = indexPath.row
        let itemProvider = NSItemProvider()
        return [UIDragItem(itemProvider: itemProvider)]
    }
    

    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        let rect = CGRect(x: 0,
                          y: 0,
                          width: 150,
                          height: 50)
        parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)

        
        return parameters
    }
}

// MARK: - UITableViewDropDelegate

extension SplitBillVC: UITableViewDropDelegate {
    
    //     Ensure that the drop session contains a drag item with a data representation
    //     that the view can consume.
    
    //     A drop proposal from a table view includes two items: a drop operation,
    //     typically .move or .copy; and an intent, which declares the action the
    //     table view will take upon receiving the items. (A drop proposal from a
    //     custom view does includes only a drop operation, not an intent.)
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    //     This delegate method is the only opportunity for accessing and loading
    //     the data representations offered in the drag item. The drop coordinator
    //     supports accessing the dropped items, updating the table view, and specifying
    //     optional animations. Local drags with one item go through the existing
    //     `tableView(_:moveRowAt:to:)` method on the data source.
    
    func ExecuteDropwithOption(indexToUpdate: Int, Qty: Int, newQty: Int) {
        if Qty != newQty {
            var roundableFlag = 0
            if arraySplitBill[indexToUpdate].productRoundableFlag {
                roundableFlag = 1
            }
            let BillLine = Order(sessionID: arraySplitBill[indexToUpdate].sessionID,
                                 orderID: arraySplitBill[indexToUpdate].orderID,
                                 productID: arraySplitBill[indexToUpdate].productID,
                                 productName: arraySplitBill[indexToUpdate].productName,
                                 productOptionPrice: arraySplitBill[indexToUpdate].productOptionPrice,
                                 productDefaultOption: arraySplitBill[indexToUpdate].productDefaultOption,
                                 productKind: arraySplitBill[indexToUpdate].sessionID,
                                 productQty: arraySplitBill[indexToUpdate].productQty,
                                 productVAT: arraySplitBill[indexToUpdate].productVAT,
                                 productRoundable: roundableFlag,
                                 payerName: arraySplitBill[indexToUpdate].payerName,
                                 billTip: arraySplitBill[indexToUpdate].billTip)
            
            arraySplitBill.insert(BillLine, at: indexToUpdate + 1)
            arraySplitBill[indexToUpdate].productQty = Qty - newQty
            arrayNotSplited[indexPathToUpdate].productQty = Qty - newQty
            arraySplitBill[indexToUpdate + 1].productQty = newQty
            arraySplitBill[indexToUpdate + 1].payerName = segmentedControlNumberOfPeople.selectedSegmentIndex + 1
            if indexPathToUpdate + 1 < arrayNotSplited.count {
                for index in indexPathToUpdate + 1...arrayNotSplited.count - 1 {
                    arrayFromToTable[index] = arrayFromToTable[index]! + 1
                }
            }
            print(arrayFromToTable)
        } else {
            arraySplitBill[indexToUpdate].payerName = segmentedControlNumberOfPeople.selectedSegmentIndex + 1
            print(indexPathToUpdate)
            arrayNotSplited.remove(at: indexPathToUpdate)
            
            if indexPathToUpdate < arrayNotSplited.count {
                for index in indexPathToUpdate...arrayNotSplited.count - 1 {
                    arrayFromToTable[index] = arrayFromToTable[index + 1]!
                }
            }
            arrayFromToTable.removeValue(forKey: arrayNotSplited.count)
            print(arrayFromToTable)
        }
        self.tableViewTVBill.reloadData()
        self.tableViewBillPerPerson.reloadData()
        updateSubtotals()
        self.buttonClear.isHidden = false
        self.buttonPartialBill.isEnabled = true
        if arrayFromToTable.count == 0 {
            self.buttonPartialBill.setTitle("Dividir Total Cuenta", for: .normal)
            tableViewTVBill.isHidden = true
            viewSplitedBill.slideX(WidthToIncrease: 1.4, screenWidth: self.view.frame.size.width)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        self.buttonPartialBill.isEnabled = true
        if tableView == self.tableViewBillPerPerson {
            let indexToUpdate = arrayFromToTable[indexPathToUpdate]
            let Qty = arraySplitBill[indexToUpdate!].productQty
            if Qty > 1 {
                let alertController = customUIAlertView(title: nil, message: "Cuantas unidades desea añadir?", preferredStyle: .alert)
                if Qty == 5 {
                    let fiveAction = UIAlertAction(title: "5", style: .default) { _ in
                        self.ExecuteDropwithOption(indexToUpdate: indexToUpdate!, Qty: Qty, newQty: 5)
                    }
                    alertController.addAction(fiveAction)
                }
                if Qty >= 4 {
                    let fourAction = UIAlertAction(title: "4", style: .default) { _ in
                        self.ExecuteDropwithOption(indexToUpdate: indexToUpdate!, Qty: Qty, newQty: 4)
                    }
                    alertController.addAction(fourAction)
                }
                if Qty >= 3 {
                    let threeAction = UIAlertAction(title: "3", style: .default) { _ in
                        self.ExecuteDropwithOption(indexToUpdate: indexToUpdate!, Qty: Qty, newQty: 3)
                    }
                    alertController.addAction(threeAction)
                }
                if Qty >= 2 {
                    let twoAction = UIAlertAction(title: "2", style: .default) { _ in
                        self.ExecuteDropwithOption(indexToUpdate: indexToUpdate!, Qty: Qty, newQty: 2)
                    }
                    alertController.addAction(twoAction)
                    
                    let oneAction = UIAlertAction(title: "1", style: .default) { _ in
                        self.ExecuteDropwithOption(indexToUpdate: indexToUpdate!, Qty: Qty, newQty: 1)
                    }
                    alertController.addAction(oneAction)
                }
                self.present(alertController, animated: true)
            } else {
                self.ExecuteDropwithOption(indexToUpdate: indexToUpdate!, Qty: Qty, newQty: 1)
            }
        }
    }
}

// MARK: -  UITableViewDataSource, UITableViewDelegate

extension SplitBillVC:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //        if tableView == self.tableView {
        //         model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
        //         }
        //
        //         if tableView == self.tableView1 {
        //         model.moveItem1(at: sourceIndexPath.row, to: destinationIndexPath.row)
        //         }
    }
}

