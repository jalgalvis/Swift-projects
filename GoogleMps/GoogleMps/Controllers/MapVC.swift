import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import MapKit


class MapVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    
    
    //    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet var filterView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var filterButton: UIButton!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var json = JSON()
    var nearbyRestaurantsFiltered  = [Customer]()
    
    
    
    
    
    @IBAction func buttonFilter(_ sender: UIButton) {
        if filterView.transform == .identity {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                self.filterView.transform = CGAffineTransform(translationX: 0, y: -self.filterView.frame.height + self.filterButton.frame.height + 50 )
                self.filterButton.transform = CGAffineTransform(rotationAngle: 3.14)
                
            })
            
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                self.filterView.transform = .identity
                self.filterButton.transform = .identity
            })
        }
    }
    
    
    
    
    
    @IBOutlet var optionButtons: [UIButton]!
    
    
    @IBAction func buttonFilterOptions(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.3, y: 2)
        sender.backgroundColor = sender.backgroundColor == UIColor.orange ? UIColor.clear : UIColor.orange

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            sender.transform = .identity

            
        })
        
        
        switch sender.tag {
        case optionsGroup.eatIn.rawValue:
            defalultUserOptions.eatIn = !defalultUserOptions.eatIn
        case optionsGroup.takeAway.rawValue:
            defalultUserOptions.takeAway = !defalultUserOptions.takeAway
        case optionsGroup.delivery.rawValue:
            defalultUserOptions.delivery = !defalultUserOptions.delivery
        case optionsGroup.chicken.rawValue:
            defalultUserOptions.chicken = !defalultUserOptions.chicken
        case optionsGroup.beef.rawValue:
            defalultUserOptions.beef = !defalultUserOptions.beef
        case optionsGroup.pork.rawValue:
            defalultUserOptions.pork = !defalultUserOptions.pork
        case optionsGroup.fish.rawValue:
            defalultUserOptions.fish = !defalultUserOptions.fish
        case optionsGroup.seaFood.rawValue:
            defalultUserOptions.seaFood = !defalultUserOptions.seaFood
        case optionsGroup.vegetarian.rawValue:
            defalultUserOptions.vegetarian = !defalultUserOptions.vegetarian
            
            
        default:
            print("buttonOption")
        }
        nearbyRestaurantsFiltered = customerList.filter {
            (defalultUserOptions.eatIn && $0.eatInOption == defalultUserOptions.eatIn) ||
                (defalultUserOptions.takeAway && $0.takeAwayOption == defalultUserOptions.takeAway) ||
                (defalultUserOptions.delivery && $0.deliveryOption == defalultUserOptions.delivery)
        }
        nearbyRestaurantsFiltered = nearbyRestaurantsFiltered.filter {
            
            (defalultUserOptions.chicken && $0.chickenOption == defalultUserOptions.chicken) ||
                (defalultUserOptions.beef && $0.beefOption == defalultUserOptions.beef) ||
                (defalultUserOptions.pork && $0.porkOption == defalultUserOptions.pork) ||
                (defalultUserOptions.fish && $0.fishOption == defalultUserOptions.fish) ||
                (defalultUserOptions.seaFood && $0.seaFoodOption == defalultUserOptions.seaFood) ||
                (defalultUserOptions.vegetarian && $0.vegetarianOption == defalultUserOptions.vegetarian)
            
            
            
        }
        
        
        
        mapView.clear()
        if nearbyRestaurantsFiltered.count > 0 {
            for index in 0...self.nearbyRestaurantsFiltered.count - 1 {
                
                
                
                let restaurantLocation = CLLocationCoordinate2D(latitude: self.nearbyRestaurantsFiltered[index].latitude, longitude: self.nearbyRestaurantsFiltered[index].longitude)
                self.createMarker(titleMarker: self.nearbyRestaurantsFiltered[index].name, snippetMarker: "\(nearbyRestaurantsFiltered[index].distance ?? 24) m", position: restaurantLocation, tag: index)
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        print("initiating")
        
        filterView.frame = CGRect(x: 0, y: mapView.frame.height - filterButton.frame.height, width: filterView.frame.width, height: filterView.frame.height)
        
        mapView.addSubview(filterView)
        
        
        optionButtons.sort {$0.tag < $1.tag}
        optionButtons.forEach { $0.backgroundColor = UIColor.orange }
        
        

        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        //        locationManager.startMonitoringSignificantLocationChanges()
        
        if let location = locationManager.location?.coordinate {
            currentLocation = location
            
            locationManager.stopUpdatingLocation()
        }
                        currentLocation = CLLocationCoordinate2D(latitude: 4.732354000, longitude: -74.05297200)
        
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
                customerList = try JSONDecoder().decode([Customer].self, from: data)
                semaphore.signal()

            } catch let jsonErr { print("Error serializing json:", jsonErr)}
        }
        task.resume()
        
        let timeout = DispatchTime.now() + .seconds(20)
        if semaphore.wait(timeout: timeout) == .timedOut {
            print("error") // if the process take too much time returns a blank array, which is a flag to start again.
        }
        
        
        customerList.forEach {
            
            
            let coordinate₀ = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            let coordinate₁ = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            $0.distance = Int(coordinate₀.distance(from: coordinate₁))
            print($0.distance ?? 24)
            
        }
        nearbyRestaurantsFiltered = customerList.filter {
            (defalultUserOptions.eatIn && $0.eatInOption == defalultUserOptions.eatIn) ||
                (defalultUserOptions.takeAway && $0.takeAwayOption == defalultUserOptions.takeAway) ||
                (defalultUserOptions.delivery && $0.deliveryOption == defalultUserOptions.delivery)
        }
        nearbyRestaurantsFiltered = nearbyRestaurantsFiltered.filter {
            
            (defalultUserOptions.chicken && $0.chickenOption == defalultUserOptions.chicken) ||
                (defalultUserOptions.beef && $0.beefOption == defalultUserOptions.beef) ||
                (defalultUserOptions.pork && $0.porkOption == defalultUserOptions.pork) ||
                (defalultUserOptions.fish && $0.fishOption == defalultUserOptions.fish) ||
                (defalultUserOptions.seaFood && $0.seaFoodOption == defalultUserOptions.seaFood) ||
                (defalultUserOptions.vegetarian && $0.vegetarianOption == defalultUserOptions.vegetarian)
            
            
            
        }
        
        //Map initiation code
        
        let camera = GMSCameraPosition.camera(withTarget: currentLocation, zoom: 17)
        
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "DarkMapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        
        //        REQUEST DIRECTIONS OF ALL RESTAURANTS TO GET DISTANCE AND ROUTEPOINTS THEN WAIT TO CREATE MARKERS
        
        //        let group = DispatchGroup()
        //        for index in 0...nearbyRestaurants.count - 1 {
        //            group.enter()
        //            getGoogleMapsInfo(startLocation: currentLocation, restaurant: nearbyRestaurants[index]) { (distance, routePoints) in
        //                self.nearbyRestaurants[index].distance = distance
        //                self.nearbyRestaurants[index].routePoints = routePoints
        //                group.leave()
        //            }
        //
        //        }
        //
        //
        //
        //
        //        group.notify(queue: .main) {
        //            for index in 0...self.nearbyRestaurants.count - 1 {
        //                let restaurantLocation = CLLocationCoordinate2D(latitude: self.nearbyRestaurants[index].latitude, longitude: self.nearbyRestaurants[index].longitude)
        //                self.createMarker(titleMarker: self.nearbyRestaurants[index].name, snippetMarker: "\(self.nearbyRestaurants[index].distance) m", position: restaurantLocation, tag: index)
        //            }
        //        }
        
        if nearbyRestaurantsFiltered.count == 0 {return} // didn't find any restaurant
        
//        print markers
        
        for index in 0...self.nearbyRestaurantsFiltered.count - 1 {
            
            let restaurantLocation = CLLocationCoordinate2D(latitude: self.nearbyRestaurantsFiltered[index].latitude, longitude: self.nearbyRestaurantsFiltered[index].longitude)
            self.createMarker(titleMarker: self.nearbyRestaurantsFiltered[index].name, snippetMarker: "\(nearbyRestaurantsFiltered[index].distance ?? 24) m", position: restaurantLocation, tag: index)
        }
        
        
    }
    // MARK: function for create a marker pin on map
    
    func createMarker(titleMarker: String, snippetMarker: String, position: CLLocationCoordinate2D, tag: Int) {
        let marker = GMSMarker()
        marker.position = position
        marker.title = titleMarker
        marker.snippet = snippetMarker
        marker.appearAnimation = .pop
        marker.map = mapView
        
        if let customMarker = Bundle.main.loadNibNamed("Pin", owner: self, options: nil)?.first as? CustomMarkerViewWithImage {
            customMarker.customViewLabel.text = snippetMarker
            customMarker.tag = tag
            marker.iconView = customMarker
            
        }
        
    }
    
    //MARK: - Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    //MARK: - Location Manager delegates
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let tag = (marker.iconView?.tag) else {return nil}
        
        let restaurant = nearbyRestaurantsFiltered[tag]
        
        if let customRestaurantPreview = Bundle.main.loadNibNamed("RestaurantPreviewWindow", owner: self, options: nil)?.first as? RestaurantPreviewView {
            customRestaurantPreview.image.image = restaurant.image
            customRestaurantPreview.name.text = restaurant.name
            customRestaurantPreview.rating.text = String(restaurant.rating)
            customRestaurantPreview.distance.text = "\(restaurant.distance ?? 0) m"
            
            customRestaurantPreview.eatInIcon.tintColor = restaurant.eatInOption ? UIColor.clear : UIColor.green
            customRestaurantPreview.takeAwayIcon.tintColor = restaurant.takeAwayOption ? UIColor.clear : UIColor.green
            customRestaurantPreview.deliveryIcon.tintColor = restaurant.deliveryOption ? UIColor.clear : UIColor.green
            
            
            return customRestaurantPreview
            
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.isMyLocationEnabled = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
            self.filterView.transform = .identity
            self.filterButton.transform = .identity
        }, completion: nil)
        
        //        UIView.animate(withDuration: 0.5, animations: {
        //            self.blurEffectView.transform = .identity
        //            self.filterButton.transform = .identity
        //        })
        
        mapView.clear()
        
        
        for index in 0...self.nearbyRestaurantsFiltered.count - 1 {
            let restaurantLocation = CLLocationCoordinate2D(latitude: self.nearbyRestaurantsFiltered[index].latitude, longitude: self.nearbyRestaurantsFiltered[index].longitude)
            self.createMarker(titleMarker: self.nearbyRestaurantsFiltered[index].name, snippetMarker: "\(self.nearbyRestaurantsFiltered[index].distance ?? 24) m", position: restaurantLocation, tag: index)
        }
        marker.map = mapView
        
        
        guard let tag = (marker.iconView?.tag) else {return false}
        
        //        WAIT FOR THE REQUEST TO GOOGLE TO COMPLETE
        getGoogleMapsInfo(startLocation: currentLocation, restaurant: nearbyRestaurantsFiltered[tag]) { (distance, routePoints) in
            print("walking distance = \(distance)")
            self.nearbyRestaurantsFiltered[tag].routePoints = routePoints
            let path = GMSPath.init(fromEncodedPath: routePoints)
            let polyline = GMSPolyline.init(path: path)
            polyline.strokeWidth = 4
            polyline.strokeColor = UIColor.red
            polyline.map = self.mapView
            
        }
        
        
        
        return false
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let tag = (marker.iconView?.tag) else {return}
        print("this is \(nearbyRestaurantsFiltered[tag].name)")
    }
    
    
    func getGoogleMapsInfo(startLocation: CLLocationCoordinate2D, restaurant: Customer, completion: @escaping (_ distance: Int, _ routePoints: String)  -> Void){
        
        let endLocation = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let origin = "\(startLocation.latitude),\(startLocation.longitude)"
        let destination = "\(endLocation.latitude),\(endLocation.longitude)"
        var distance = 0
        var routePoints = ""
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?key=\(serverKey)&origin=\(origin)&destination=\(destination)&mode=walking"
        Alamofire.request(url).responseJSON { response in
            
            switch response.result {
            case .success:
                print(response.request as Any)  // original URL request
                print(response.response as Any) // HTTP URL response
                print(response.data as Any)     // server data
                print(response.result as Any)   // result of response serialization
                
                do {
                    self.json = try JSON(data: response.data!)
                    
                    
                    print(self.json)
                    distance = Int(truncating: self.json["routes"][0]["legs"][0]["distance"]["value"].numberValue)
                    
                    
                    let route = self.json["routes"].arrayValue.first
                    let routeOverviewPolyline = route!["overview_polyline"].dictionary
                    routePoints = (routeOverviewPolyline?["points"]?.stringValue)!
                    completion(distance, routePoints)
                } catch {
                    print("error JSON")
                }
                
                
            case .failure(let error):
                print(error)
                completion(distance, routePoints)
            }
            
        }
        
        
    }
    
}

