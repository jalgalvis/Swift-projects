import UIKit
import Firebase
import RealmSwift
import SVProgressHUD


@UIApplicationMain


// MARK: - App Delegate

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "No path for Realm")
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.gradient)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        evaluateSession()
        return true
    }
    
    func evaluateSession () {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if !Session.existSessionRealm() {
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoggedVC") as! LoggedVC
            let firstViewController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = firstViewController

        } else {
            let sessionInfo = Session.getsessionRealm()
            let SessionStatus = receiveDataFromServerSessionStatus(sessionID: sessionInfo.sessionID)
            // 1 means that Session is active but there is not a pending bill (bill payed)
            // 2 means that Session is active but there is not a pending bill (not orders yet)
            // 3 means that Session is active and there is a pending bill
            
            if SessionStatus == 3 {
                let firstViewController = storyboard.instantiateViewController(withIdentifier: "TabBarView") as! CustomTabVC
                self.window?.rootViewController = firstViewController

            } else {
                let firstViewController = storyboard.instantiateViewController(withIdentifier: "QRReaderNC") as!
                UINavigationController
                self.window?.rootViewController = firstViewController

            }

        }
        self.window?.makeKeyAndVisible()
    }
}
