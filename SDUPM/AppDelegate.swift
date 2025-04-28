//
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let token = UserDefaults.standard.bool(forKey: LoginView.isActive)
        
        if token {
            window?.rootViewController = UINavigationController(rootViewController: NavigationViewModel())
        } else {
            window?.rootViewController = UINavigationController(rootViewController: SignInView())
        }
        window?.makeKeyAndVisible()
        return true
    }
}

