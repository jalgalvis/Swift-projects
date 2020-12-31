//
//  MapViewController.swift
//  MapsTraining
//
//  Created by Juan Alejandro Galvis on 6/16/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit
import MapKit

class MapKitCurrentLocationVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var MapViewCurrentLocation: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.stopUpdatingLocation()

        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.010, longitudeDelta: 0.010)
        let region = MKCoordinateRegion(center: center, span: span)
        
        MapViewCurrentLocation.setRegion(region, animated: true)
        MapViewCurrentLocation.showsUserLocation = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
