import ErrorHandling
import FirebaseDataStore
import Foundation
import Logging
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ConsoleLogger.configure()
        FirebaseAPI.configure()
        ErrorHandler.configure()
        
        return true
    }
}
