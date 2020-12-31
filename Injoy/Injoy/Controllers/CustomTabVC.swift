import UIKit

class CustomTabVC: UITabBarController,UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item", item.tag )
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller", viewController)
        print("index", tabBarController.selectedIndex )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionInfo = Session.getsessionRealm()

        UITabBar.appearance().barTintColor = sessionInfo.placeColor
    }
}

