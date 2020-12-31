
import Foundation
import UIKit

class NavigationController : UINavigationController {
    
    @IBOutlet weak var NavigationControllerBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sessionInfo = Session.getsessionRealm()

        
        // Status bar white font
        self.navigationBar.backgroundColor = sessionInfo.placeColor
        self.navigationBar.tintColor = sessionInfo.placeColor
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
    }
}
