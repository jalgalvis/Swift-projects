//
//  ViewController.swift
//  MapsTraining
//
//  Created by Juan Alejandro Galvis on 6/16/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit
import MapKit

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubtitle:String, location: CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubtitle
        self.coordinate = location
    }
    
}

class MapKitRouteVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sourceLocation = CLLocationCoordinate2D(latitude: 40.714584, longitude: -74.007228)
        let destinationLocation = CLLocationCoordinate2D(latitude: 40.714210, longitude: -74.008660)
        
        let sourcePin = customPin(pinTitle: "Home", pinSubtitle: "Aqui muemo", location: sourceLocation)
        let destinationPin = customPin(pinTitle: "Supermarket", pinSubtitle: "Aqui compro", location: destinationLocation)
        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        directionRequest.transportType = .any
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print("we have error getting directions \(error.localizedDescription)")
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rectangle = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion.init(rectangle),animated: true)
        }
        
        self.mapView.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - MapView delegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer (overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

