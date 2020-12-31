import UIKit

var productList = [Int:Product]()

class MealListVC: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var tableViewMeal: UITableView!
    @IBOutlet weak var segmentedControlProduct: UISegmentedControl!
    @IBOutlet weak var viewProductSegment: UIView!
    @IBOutlet weak var buttonCheckOrder: UIButton!
    
    @IBOutlet weak var barMenu: UICollectionView!
    var listOfProductsForTableUpdate = [Product]()
    var order = [Order]()
    var productOptions: [String] = []
    var productOptionsListForPickerView: [String] = []
    var pricePerOption: [String:Int] = [:]
    let sessionInfo = Session.getsessionRealm()
    var productKind = [String]()
    var productKindUnique = [String]()
    var horizontalBar: UIView = {
        let hb = UIView()
        hb.backgroundColor = UIColor.white
        hb.layer.cornerRadius = 2
        hb.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return hb
    }()
    
    //MARK: Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barMenu.register(barMenuCell.self, forCellWithReuseIdentifier: "CellId")
        barMenu.backgroundColor = sessionInfo.placeColor
        view.tintColor = sessionInfo.placeColor
        
        viewProductSegment.backgroundColor = sessionInfo.placeColor
        segmentedControlProduct.backgroundColor = UIColor.clear
        
        
        
        
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        segmentedControlProduct.setTitleTextAttributes((font as! [NSAttributedString.Key : Any]), for: .normal)
        segmentedControlProduct.layer.masksToBounds = true
        
        // Select unique Product Kind for the UISegmented Control
        // Also select the most popular
        
        let CheckOffer = productList.values.filter({ $0.offerIndicator == true }).count
        
        if CheckOffer == 0 {
            segmentedControlProduct.removeSegment(at: 1, animated: false)
        }
        
        productKind = productList.values.filter {$0.popularIndicator == true}.map{$0.productKind}.sorted(by: {$0 < $1}) // Select all the records of the field
        productKindUnique = Array(Set(productKind)) //Select unique records
        
        segmentedControlProduct.selectedSegmentIndex = 0
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        barMenu.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
        updateTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let index = self.tableViewMeal.indexPathForSelectedRow {
            self.tableViewMeal.deselectRow(at: index, animated: true)
        }
        buttonCheckOrder.isHidden = !(order.count > 0)
        
        
        horizontalBar.frame = CGRect(x: 0, y: barMenu.frame.height-10, width: (UIScreen.main.bounds.width / 7) * 2, height: 4)
        barMenu.addSubview(horizontalBar)
        positionBarMenu()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier  == "segueMenu2Product" {
            
            if let ProductDetailViewController = segue.destination as? ProductVC, let SelectedProductCell = sender as? ReusableCell, let indexPath = tableViewMeal.indexPath(for: SelectedProductCell) {
                let selectedMeal = listOfProductsForTableUpdate[indexPath.row]
                ProductDetailViewController.product = selectedMeal
                ProductDetailViewController.order = order
            }
        }
        
        if segue.identifier == "segueMenu2Order" {
            if let DestinationVC = segue.destination as? OrderVC  {
                DestinationVC.order = order
                //                DestinationVC.sessionInfo = sessionInfo
            }
        }
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? ProductVC {
            order = sourceViewController.order
        }
        if sender.source is OrderVC{
            order.removeAll()
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    func updateTable () {
        let semaphore = DispatchSemaphore(value: 0)
        receiveDataFromServerProducts (placeID: sessionInfo.placeID) { (list) in
            productList = Dictionary(grouping: list.sorted(by: {$0.productID < $1.productID}), by: { $0.productID}).mapValues { $0.first! }
            semaphore.signal()
        }
        semaphore.wait()

            
            self.listOfProductsForTableUpdate = [Product]()
            switch self.segmentedControlProduct.titleForSegment(at: self.segmentedControlProduct.selectedSegmentIndex) {
            case "Populares"?:
                if let productKindUniqueIndex = self.barMenu.indexPathsForSelectedItems?.first {
                    self.listOfProductsForTableUpdate = productList.values.filter {$0.productKind == self.productKindUnique[productKindUniqueIndex.row] && $0.popularIndicator == true}
                }
            case "Ofertas"?:
                if let productKindUniqueIndex = self.barMenu.indexPathsForSelectedItems?.first {
                    self.listOfProductsForTableUpdate = productList.values.filter {$0.productKind == self.productKindUnique[productKindUniqueIndex.row] && $0.offerIndicator == true}
                }
            default:
                if let productKindUniqueIndex = self.barMenu.indexPathsForSelectedItems?.first {
                    self.listOfProductsForTableUpdate = productList.values.filter {$0.productKind == self.productKindUnique[productKindUniqueIndex.row]}
                }
            }
            self.tableViewMeal.reloadData()
    }
    
    //MARK: Segmented Control Methods
    
    
    
    @IBAction func ProductSegmentChange(_ sender: UISegmentedControl) {
        var ProductKind: [String]
        switch segmentedControlProduct.titleForSegment(at: segmentedControlProduct.selectedSegmentIndex) {
        case "Populares"?:
            ProductKind = productList.values.filter {$0.popularIndicator == true}.map {$0.productKind} // Select all the records of the field
        case "Ofertas"?:
            ProductKind = productList.values.filter {$0.offerIndicator == true}.map {$0.productKind} // Select all the records of the field
        default:
            ProductKind = productList.values.map {$0.productKind} // Select all the records of the field
        }
        productKindUnique = Array(Set(ProductKind)) //Select unique records
        barMenu.reloadData()
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        barMenu.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
        positionBarMenu()
        horizontalBar.frame.origin.x = 0
        updateTable()
    }
    
    func positionBarMenu() {
        let barMenuCurrentNumberOfItems = barMenu.numberOfItems(inSection: 0)
        if  barMenuCurrentNumberOfItems < 4 {
            barMenu.frame = CGRect(x: 0, y: barMenu.frame.origin.y, width: (UIScreen.main.bounds.width / 7) * (CGFloat(barMenu.numberOfItems(inSection: 0)) * 2), height: barMenu.frame.height)
            barMenu.center.x = viewProductSegment.center.x
        } else {
            barMenu.frame = CGRect(x: 0, y: barMenu.frame.origin.y, width: UIScreen.main.bounds.width, height: barMenu.frame.height)
        }
        
    }
    
}



//MARK: - UITableViewDataSource Methods

extension MealListVC: UITableViewDataSource {
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfProductsForTableUpdate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell") as! ReusableCell
        let product = listOfProductsForTableUpdate[indexPath.row]
        
        DispatchQueue.main.async {
            cell.productPhoto.image = UIImage()
            cell.productPhoto.image = product.photo
        }
        cell.productName.text = product.productName
        pricePerOption = product.productOptionPrice
        
        // Sort dictionary of Options from cheapest to Most Expensive
        let ProductOptionPriceSorted = pricePerOption.sorted(by: { $0.value < $1.value })
        
        // Array for PickerView
        productOptionsListForPickerView = ProductOptionPriceSorted.map { $0.key }
        productOptions = productOptionsListForPickerView
        
        for (index,element) in productOptionsListForPickerView.enumerated() {
            productOptionsListForPickerView[index] += "   $ \(String(format: "%d", locale: Locale.current, product.productOptionPrice[element]!))"
        }
        
        cell.pickerData = productOptionsListForPickerView
        cell.pickerOptions.reloadAllComponents()
        if cell.pickerOptions.numberOfRows(inComponent: 0) > 1 {
            cell.pickerOptions.selectRow(1, inComponent: 0, animated: true)
        }
        return cell
    }
}

extension MealListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productKindUnique.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! barMenuCell
        cell.backgroundColor = sessionInfo.placeColor
        cell.menuTitle.text = productKindUnique[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: (UIScreen.main.bounds.width / 7) * 2, height: barMenu.frame.height)
        return cellSize
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.horizontalBar.frame.origin.x =  self.barMenu.cellForItem(at: indexPath)?.frame.origin.x ?? 0
            if self.barMenu.numberOfItems(inSection: 0) > 3 && self.barMenu.indexPathsForVisibleItems.last == indexPath {
                if self.barMenu.numberOfItems(inSection: 0) > indexPath.row + 1 {
                    var newIndexPath = indexPath
                    newIndexPath.row += 1
                    self.barMenu.scrollToItem(at: newIndexPath, at: [], animated: false)
                } else {
                    self.barMenu.scrollToItem(at: indexPath, at: [], animated: false)
                }
                
            } else if self.barMenu.numberOfItems(inSection: 0) > 0 && self.barMenu.indexPathsForVisibleItems.first == indexPath {
                var newIndexPath = indexPath
                newIndexPath.row -= 1
                self.barMenu.scrollToItem(at: newIndexPath, at: [], animated: false)
                
            } else {
                self.barMenu.scrollToItem(at: indexPath, at: [], animated: false)
            }
        })
        
        updateTable()
        
    }
    
}

class barMenuCell: UICollectionViewCell {
    let menuTitle: UILabel = {
        let mt = UILabel()
        mt.textColor = UIColor.lightGray
        mt.textAlignment = .center
        return mt
    }()
    
    override var isHighlighted: Bool {
        didSet {
            menuTitle.textColor = isHighlighted ? UIColor.white : UIColor.lightGray
        }
    }
    
    override var isSelected:  Bool {
        didSet {
            menuTitle.textColor = isSelected ? UIColor.white : UIColor.lightGray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(menuTitle)
        menuTitle.center = contentView.center
        menuTitle.frame = contentView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




