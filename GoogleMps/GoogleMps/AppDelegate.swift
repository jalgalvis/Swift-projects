//
//  AppDelegate.swift
//  GoogleMps
//
//  Created by Juan Alejandro Galvis on 18/6/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit
import GoogleMaps

let key = "AIzaSyDLUKkHX_awEU35AKlVKTjFtfTZAq9j3Pk"
let serverKey = "AIzaSyAg2-whboXtBSbMo-jMFmwMyyEz6lRtqI0"


extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(key)
        return true
    }

}



