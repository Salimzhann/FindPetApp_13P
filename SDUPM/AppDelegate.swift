//
import UIKit
import UserNotifications

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
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleDailyNotification()
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "no error")")
            }
        }
        
        return true
    }
    
    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget!"
        content.body = "Come back and check the app today 📱"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 1 // каждый день в 10:00 утра
        dateComponents.minute = 49

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

