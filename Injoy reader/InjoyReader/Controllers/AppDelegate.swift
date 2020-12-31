import UIKit


@UIApplicationMain


// MARK: - App Delegate

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

}

// MARK: - UIView Extension


extension UIView {
    func slideX(WidthToIncrease:CGFloat, screenWidth:CGFloat) {
        
        let yPosition = self.frame.origin.y
        let width = self.frame.width * WidthToIncrease
        let xPosition = (screenWidth - width) / 2
        let height = self.frame.height
        
        UIView.animate(withDuration: 0.8, animations: {
            self.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        })
    }
    
    func slideXback(WidthToDecrease:CGFloat, screenWidth:CGFloat) {
        
        let width = self.frame.width * WidthToDecrease
        let yPosition = self.frame.origin.y
        let xPosition = screenWidth - width - 10
        let height = self.frame.height
        
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

// MARK: - UIView Extension


extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}


// MARK: - @IBDesignableS

// @IBDesignable class MySegmentedControl: UISegmentedControl {

@IBDesignable class DesignableSegmentedControl: UISegmentedControl {
    
    @IBInspectable var height: CGFloat = 29 {
        didSet {
            let centerSave = center
            frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
            center = centerSave
        }
    }
    
    
    @IBInspectable var multilinesMode: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for segment in self.subviews {
            for subview in segment.subviews {
                if let segmentLabel = subview as? UILabel {
                    segmentLabel.frame = CGRect(x: 0, y: 0, width: segmentLabel.frame.size.width, height: segmentLabel.frame.size.height * 1.6)
                    if (multilinesMode == true)
                    {
                        segmentLabel.numberOfLines = 0
                    }
                    else
                    {
                        segmentLabel.numberOfLines = 1
                    }
                }
            }
        }
    }
    
}

@IBDesignable class DesignableView: UIView {
}

@IBDesignable class DesignableButton: UIButton {
}

@IBDesignable class DesignableLabel: UILabel {
}

