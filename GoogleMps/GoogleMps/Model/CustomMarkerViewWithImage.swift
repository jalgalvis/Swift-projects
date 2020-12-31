import Foundation
import UIKit


class CustomMarkerViewWithImage: UIView {
    @IBOutlet weak var customViewImage: UIImageView!
    @IBOutlet weak var customViewLabel: UILabel!
}

//class CustomMarkerViewWithoutXibFile: UIView {
//    var labelDistance: String!
//    var labelTag: String!
//    
//    init(tag: Int, distance: String) {
//        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        self.labelDistance = distance
//        self.layer.backgroundColor = UIColor.black.cgColor
//        self.layer.borderColor = UIColor.white.cgColor
//        self.layer.cornerRadius = 25
//        self.layer.borderWidth = 4
//        self.tag = tag
//        setupViews()
//    }
//    
//    func setupViews() {
//        let lblDistance = UILabel(frame: CGRect(x: 0, y: 32, width: 50, height: 10))
//        lblDistance.text = labelDistance
//        lblDistance.font = UIFont.systemFont(ofSize: 10)
//        lblDistance.textColor = UIColor.white
//        lblDistance.textAlignment = .center
//        self.addSubview(lblDistance)
//        
//        let lblTag = UILabel(frame: CGRect(x: 0, y: 10, width: 50, height: 20))
//        lblTag.text = String(tag)
//        //        lblTag.font = UIFont.systemFont(ofSize: 20)
//        lblTag.font = UIFont.boldSystemFont(ofSize: 20)
//        lblTag.textColor = UIColor.white
//        lblTag.textAlignment = .center
//        self.addSubview(lblTag)
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
