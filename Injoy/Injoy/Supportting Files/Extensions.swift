//
//  Extensions.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 6/10/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit


// MARK: - UIView Extension


extension UIView {
    func slideX(WidthToIncrease:CGFloat, screenWidth:CGFloat) {
        
        let yPosition = self.frame.origin.y
        let width = self.frame.width * WidthToIncrease
        let xPosition = (screenWidth - width) / 2
        let height = self.frame.height
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.8, animations: {
            self.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        })
    }
    
    func slideXback(WidthToDecrease:CGFloat, screenWidth:CGFloat) {
        
        let width = self.frame.width * WidthToDecrease
        let yPosition = self.frame.origin.y
        let xPosition = screenWidth - width - 10
        let height = self.frame.height
        
        self.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.8, animations: {
            self.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            
        })
    }
}

// MARK: - UIColor Extension

extension UIColor {
    convenience init(colorCode: String, alpha: Float = 1.0){
        let scanner = Scanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        self.init(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
}



// MARK: - UIImage Extension


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

