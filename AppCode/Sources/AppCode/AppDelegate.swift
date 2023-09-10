import FirebaseClient
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseClient.configure()
        ConsoleLogger.configure()
        ErrorHandler.configure()
        
        return true
    }
}
